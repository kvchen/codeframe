Docker   = require "dockerode"

fs       = require "fs-extra"
Joi      = require "joi"
path     = require "path"
sanitize = require "sanitize-filename"
winston  = require "winston"
uuid     = require "node-uuid"

dockerConfig    = require "../config/docker.json"
containerConfig = require "../config/container.json"


# Make sure the Docker socket is running and create a client
if process.env.NODE_ENV isnt 'test'
  socket = process.env.DOCKER_SOCKET || dockerConfig.socket
  docker = new Docker 
    socketPath: socket

  status = fs.statSync socket
  if !status.isSocket()
    winston.error "Docker client failed to start!"
  else
    winston.info "Docker client successfully instantiated"


createVolume = (files, cb) ->
  if !files?
    return cb new Error "No files provided"

  envUUID = uuid.v4()

  basePath = path.dirname(require.main.filename)
  volume = path.join basePath, "tmp", envUUID

  fileSchema = Joi.object().keys
    name: Joi.string().regex(/^[\w\-. ]+$/).required()
    contents: [
      Joi.string()
      Joi.array()
    ]

  writeVolume volume, 0, files, fileSchema, (err) ->
    return cb err if err
    cb null, volume


writeVolume = (dir, depth, files, fileSchema, cb) ->
  fs.ensureDir dir, (err) ->
    return cb err if err

    winston.info "Created directory %s", dir

    if depth > 10
      return cb new Error "Maximum path depth exceeded"

    folderSchema = Joi.array().includes(fileSchema)
    Joi.validate files, folderSchema, (err, value) ->
      return cb err if err

      unwrittenContents = files.length
      for file in files
        filename = sanitize file.name

        # Treat nested arrays like folders
        if file.contents instanceof Array
          writeVolume path.join(dir, filename), depth+1, file.contents, (err) ->
            return cb err if err
            
            if --unwrittenContents == 0
              cb null
        else
          fs.writeFile path.join(dir, filename), file.contents, (err) ->
            return cb err if err
            winston.info "Wrote file %s", path.join(dir, filename)

            if --unwrittenContents == 0
              cb null


runContainer = (language, entrypoint, volume, cb) -> 
  volumes = {}
  volumes[containerConfig.code] = {}
  volumes[containerConfig.env] = {}

  createOptions = 
    Image: containerConfig.image
    Memory: containerConfig.memory
    DisableNetwork: containerConfig.disableNetwork
    Cmd: [
      language
      path.join containerConfig.env, entrypoint
    ] 
    Volumes: volumes

  attachOptions = 
    stream: true
    stdout: true
    stderr: true
    tty: false

  startOptions = 
    Binds: ["#{volume}:#{containerConfig.code}:ro"]

  docker.createContainer createOptions, (err, container) ->
    winston.info "%s: Container created", container.id
    return cb err if err

    container.attach attachOptions, (err, stream) ->
      return cb err if err

      container.start startOptions, (err, data) ->
        return cb err if err

        output = ""
        chunksRead = 0
        timedOut = truncated = false

        timeout = setTimeout (() ->
          winston.warn "%s: Code timed out", container.id
          timedOut = true
          stream.destroy()
        ), containerConfig.timeout

        stream.on "data", (chunk) ->
          output += chunk
          chunksRead++
          if chunksRead > 100
            winston.warn "%s: Output truncated", container.id
            truncated = true
            stream.destroy()

        stream.on "end", () ->
          clearTimeout timeout
          container.inspect (err, containerData) ->
            return cb err if err

            resData = 
              exitCode: containerData.State.ExitCode
              timedOut: timedOut
              truncated: truncated
              output: output
            cb null, resData

            cleanup container, volume, (err) ->
              if err
                winston.warn "%s: Error in cleaning up container!", container.id


cleanup = (container, volume, cb) ->
  container.remove force: true, (err, data) ->
    if err
      winston.warn "%s: Failed to remove container!", container.id
    winston.info "%s: Container removed", container.id

    fs.remove volume, (err) ->
      if err
        winston.warn "Failed to remove volume %s", volume
      winston.info "Removed volume %s", volume

      cb null


exports.createVolume = createVolume
exports.run = runContainer


