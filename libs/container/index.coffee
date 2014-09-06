Docker   = require "dockerode"

fs       = require "fs-extra"
Joi      = require "joi"
path     = require "path"
sanitize = require "sanitize-filename"
winston  = require "winston"
uuid     = require "node-uuid"

config   = require "./config.json"

if process.env.NODE_ENV isnt 'test'
  # Make sure the Docker client is running, or throw an error!
  socket = process.env.DOCKER_SOCKET || '/var/run/docker.sock';
  docker = new Docker 
    socketPath: socket

  status = fs.statSync(socket);
  if !status.isSocket()
    winston.error "Docker client failed to start!"
  else
    winston.info "Docker client successfully instantiated"


runContainer = (language, entrypoint, volume, cb) -> 
  binds = {}
  binds[config.env] = {}

  createOptions = 
    Image: config.image
    Memory: config.memory
    DisableNetwork: config.DisableNetwork
    Cmd: [language, path.join(config.env, entrypoint)]
    Volumes: binds

  attachOptions = 
    stream: true
    stdout: true
    stderr: true
    tty: false

  startOptions = 
    Binds: [volume + ":/opt/code:rw"]

  docker.createContainer createOptions, (err, container) ->
    winston.info "%s: Container created", container.id
    return cb err if err

    container.attach attachOptions, (err, stream) ->
      return cb err if err

      container.start startOptions, (err, data) ->
        return cb err if err

        output = ""
        chunksRead = 0
        timedOut = false

        timeout = setTimeout (() ->
          winston.warn "%s: Code timed out", container.id
          timedOut = true
          stream.destroy()
        ), config.timeout

        stream.on "data", (chunk) ->
          output += chunk.toString()
          chunksRead++
          if chunksRead > 100
            winston.warn "%s: Output truncated", container.id
            stream.destroy()

        stream.on "end", () ->
          clearTimeout timeout
          container.inspect (err, containerData) ->
            return cb err if err

            container.remove force: true, (err, data) ->
              winston.info "%s: Container removed", container.id

              resData = 
                timedOut: timedOut
                exitCode: containerData.State.ExitCode
                output: output
              cb null, resData


createVolume = (files, cb) ->
  if !files?
    return cb new Error "No files provided"

  envUUID = uuid.v4()

  basePath = path.dirname(require.main.filename)
  volume = path.join basePath, 'uploads', envUUID

  fileSchema = Joi.object().keys
    name: Joi.string().alphanum().min(1).max(255).required()
    contents: [Joi.string(), Joi.array()],

  writeVolume volume, 0, files, fileSchema, (err) ->
    return cb err if err
    cb null, volume


writeVolume = (dir, depth, files, fileSchema, cb) ->
  fs.ensureDir dir, (err) ->
    return cb err if err

    winston.info "Created directory %s", dir

    if depth > 10
      return cb new Error "Maximum recusion depth exceeded"

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

exports.createVolume = createVolume
exports.run = runContainer


