container = require "../libs/container"
fs        = require "fs-extra"
winston   = require "winston"

exports.run = (req, res, next) ->
  env = req.body

  container.createVolume env.files, (err, volume) ->
    if err?
      winston.error "Failed to create file volume"
      res.status(400).json
        status: "fail"
        message: err.message
    else
      container.run env.language, env.entrypoint, volume, (err, exitCode, output) ->
        fs.remove volume, (err) ->
          if err?
            winston.error "Failed to remove directory %s", volume
        if err?
          res.status(500).json
            status: "fail"
            message: err.message
        else
          res.json
            status: "success"
            data:
              exitCode: exitCode
              output: output


