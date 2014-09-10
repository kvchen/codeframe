Docker = require "dockerode"
MemoryStream = require "memorystream"

fs     = require "fs-extra"
config = require "../../config"
path   = require "path"
logger = require "winston"


# Attach to the Docker daemon
if process.env.NODE_ENV isnt 'test'
  socket = process.env.DOCKER_SOCKET || config.docker.socket
  docker = new Docker 
    socketPath: socket

  status = fs.statSync socket
  if !status.isSocket()
    logger.error "Docker client failed to start!"
  else
    logger.info "Docker client successfully instantiated"


exports.run = (language, entrypoint, bind, done) ->
  volumes = {}
  volumes[config.runner.volumes.code] = {}
  volumes[config.runner.volumes.env] = {}

  createOptions = 
    Image: config.runner.image
    Memory: config.runner.memory
    DisableNetwork: config.runner.disableNetwork
    Cmd: [
      language
      path.join config.runner.volumes.env, entrypoint
    ] 
    Volumes: volumes

  attachOptions = 
    stream: true
    stdout: true
    stderr: true
    tty: false

  startOptions = 
    Binds: ["#{bind}:#{config.runner.volumes.code}:ro"]

  docker.createContainer createOptions, (err, container) ->
    return done err if err

    logger.info "#{container.id}: Container created"
    container.attach attachOptions, (err, stream) ->
      return done err if err

      logger.info "#{container.id}: Streaming output"

      chunksRead = 0
      maxLength = config.runner.maxLength
      timedOut = truncated = false
      
      output = ""

      outputStream = new MemoryStream()
      outputStream.on "data", (data) ->
        output += data
        if ++chunksRead > maxLength
          logger.warn "#{container.id}: Output truncated"
          truncated = true
          stream.destroy()

      container.modem.demuxStream(stream, outputStream, outputStream);

      container.start startOptions, (err, data) ->
        return done err if err

        timeout = setTimeout (() ->
          logger.warn "#{container.id}: Code timed out"
          timedOut = true
          stream.destroy()
        ), config.runner.timeout

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
                logger.warn "#{container.id}: Failed to remove"
              else
                logger.info "#{container.id}: Container removed"

            fs.remove bind, (err) ->
              if err
                logger.warn "Failed to remove tmp directory #{bind}"
              else
                logger.info "Removed tmp directory #{bind}"


