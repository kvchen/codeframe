container   = require "../libs/container"
winston     = require "winston"

exports.run = (req, res, next) ->
  env = req.body

  container.createVolume env.files, (err, volume) ->
    if err

    else
      winston.info("Created file volume")
      container.run env.language, env.entrypoint, volume, (err, exitCode, output) ->
        if err
          res.json
            status: "failure"
            reason: err
        else
          if exitCode != 0
            res.json
              status: "failure"
              exitCode: exitCode
              output: output
          else
            res.json
              status: "success"
              exitCode: exitCode
              output: output