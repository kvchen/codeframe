Docker = require "dockerode"
MemoryStream = require "memorystream"

path = require "path"
logger = require "winston"
shortId = require "shortid"
uuid = require "node-uuid"

config = require "../../config"
volume = require "./volume"

runnerConfig = config.docker.runner


# Create a client attached to the Docker daemon
if process.env.NODE_ENV isnt 'test'
  socket = process.env.DOCKER_SOCKET || config.docker.socket
  docker = new Docker 
    socketPath: socket

basePath = path.dirname require.main.filename

volumes = {}
volumes[runnerConfig.volumes.code] = {}
volumes[runnerConfig.volumes.env] = {}

class Runner
  constructor: (language, entrypoint, files) ->
    @files = files
    @id = shortId.generate()

    @shared = path.join basePath, "tmp", @id

    @containerOptions = 
      Image: runnerConfig.image
      Memory: runnerConfig.memory
      NetworkDisabled: runnerConfig.networkDisabled
      Volumes: volumes
      Cmd: [
        language
        path.join runnerConfig.volumes.env, entrypoint
      ]

    @attachOptions = runnerConfig.output

    @startOptions = 
      Binds: ["#{@shared}:#{runnerConfig.volumes.code}:ro"]

  run: (done) =>
    volume.create @files, @shared, (err) =>
      return done err if err

      docker.createContainer @containerOptions, (err, container) =>
        return done err if err

        logger.info "#{@id}: Container created"
        @container = container

        container.attach @attachOptions, (err, stream) =>
          return done err if err

          logger.info "#{@id}: Streaming output"
          
          chunksRead = 0
          timedOut = false
          truncated = false

          output = ""
          outputStream = new MemoryStream()
          outputStream.on "data", (chunk) =>
            output += chunk
            if ++chunksRead > runnerConfig.maxLength
              logger.warn "#{@id}: Output truncated"
              truncated = true
              stream.destroy()

          container.modem.demuxStream stream, outputStream, outputStream

          container.start @startOptions, (err, data) =>
            return done err if err

            timeout = setTimeout ( ->
              logger.warn "#{@id}: Code timed out"
              timedOut = true
              stream.destroy()
            ), runnerConfig.timeout

            stream.on "end", ->
              clearTimeout timeout

              container.inspect (err, inspection) =>
                return done err if err

                response = 
                  exitCode: inspection.State.ExitCode
                  timedOut: timedOut
                  truncated: truncated
                  output: output

                return done null, response

  clean: (err, done) =>
    if @container
      @container.remove force: true, (err, data) =>
        if err
          logger.warn "#{@id}: Failed to remove container"
        else
          logger.info "#{@id}: Container removed"

    volume.remove @shared, (err) =>
      if err
        logger.warn "#{@id}: Failed to remove tmp directory"
      else
        logger.info "#{@id}: Removed tmp directory"

module.exports = Runner