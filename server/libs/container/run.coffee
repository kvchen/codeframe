Docker  = require "dockerode"
fs    = require "fs-extra"
path  = require "path"
winston = require "winston"

docker = new Docker
  socketPath: "/var/run/docker.sock"
winston.info("Docker client successfully initialized")

module.exports = (language, entrypoint, volume, cb) ->
  containerOptions = 
    Image: "runner"
    DisableNetwork: true
    Cmd: [
      language
      path.join "/opt/code", entrypoint
    ]
    Volumes: 
      "/opt/code": {}

  attachOptions = 
    stream: true
    stdout: true
    stderr: true
    tty: false

  startOptions = 
    Binds: [
      volume + ":/opt/code:rw"
    ]

  docker.createContainer containerOptions, (err, container) ->
    winston.info "Container %s created", container.id
    if err
      cb err, null
    else
      container.attach attachOptions, (err, stream) ->
        if err
          cb err, null
        else
          stream.setEncoding "utf-8"
          container.start startOptions, (err, data) ->
            if err
              cb err, null
            else
              output = ""
              chunksRead = 0

              stream.on "data", (chunk) ->
                output += chunk.toString()
                chunksRead++
                if (chunksRead > 20)
                  winston.info "Output length exceeded in container %s", container.id
                  output += "\n\n[Output truncated]"
                  stream.destroy()

              stream.on "end", () ->
                fs.remove volume
                container.remove {force: true}, (err, data) ->
                  winston.info "Container %s removed", container.id
                cb null, output