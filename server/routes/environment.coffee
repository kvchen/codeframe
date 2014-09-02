container   = require "../libs/container"
winston     = require "winston"

exports.run = (req, res, next) ->
  env = req.body

  container.createVolume env.files, (err, volume) ->
    container.run env.language, env.entrypoint, volume, (err, output) ->
      if err
        res.json
          status: "failure"
          reason: err
      else
        res.json
          status: "success"
          output: output