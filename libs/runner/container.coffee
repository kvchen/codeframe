Docker   = require "dockerode"
MemoryStream = require "memorystream"

fs       = require "fs-extra"
path     = require "path"
winston  = require "winston"

config = require "../../config/runner.json"


# Attach to the Docker daemon
if process.env.NODE_ENV isnt 'test'
  socket = process.env.DOCKER_SOCKET || config.docker.socket
  docker = new Docker 
    socketPath: socket

  status = fs.statSync socket
  if !status.isSocket()
    winston.error "Docker client failed to start!"
  else
    winston.info "Docker client successfully instantiated"


exports.run = (language, entrypoint, bind, done) ->
  volumes = {}
  volumes[config.container.volumes.code] = {}
  volumes[config.container.volumes.env] = {}

  createOptions = 
    Image: config.container.image
    Memory: config.container.memory
    DisableNetwork: config.container.disableNetwork
    Cmd: [
      language
      path.join config.container.volumes.env, entrypoint
    ] 
    Volumes: volumes

  attachOptions = 
    stream: true
    stdout: true
    stderr: true
    tty: false

  startOptions = 
    Binds: ["#{bind}:#{config.container.volumes.code}:ro"]

  docker.createContainer createOptions, (err, container) ->
    return done err if err

    winston.info "#{container.id}: Container created"
    container.attach attachOptions, (err, stream) ->
      return done err if err

      winston.info "#{container.id}: Streaming output"

      chunksRead = 0
      timedOut = false
      truncated = false
      output = ""

      outputStream = new MemoryStream()
      outputStream.on "data", (data) ->
        output += data
        if ++chunksRead > 100
          winston.warn "#{container.id}: Output truncated"
          truncated = true
          stream.destroy()

      container.modem.demuxStream(stream, outputStream, outputStream);

      container.start startOptions, (err, data) ->
        return done err if err

        timeout = setTimeout (() ->
          winston.warn "#{container.id}: Code timed out"
          timedOut = true
          stream.destroy()
        ), config.container.timeout

        stream.on "end", () ->
          clearTimeout timeout

          container.inspect (err, inspection) ->
            return done err if err

            resData = 
              exitCode: inspection.State.ExitCode
              timedOut: timedOut
              truncated: truncated
              output: output
            done null, resData

            container.remove force: true, (err, data) ->
              if err
                winston.warn "#{container.id}: Failed to remove"
              else
                winston.info "#{container.id}: Container removed"

            fs.remove bind, (err) ->
              if err
                winston.warn "Failed to remove tmp directory #{bind}"
              else
                winston.info "Removed tmp directory #{bind}"


