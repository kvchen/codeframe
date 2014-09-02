container   = require "../libs/container"
winston     = require "winston"

exports.run = (req, res, next) ->
  env = req.body

  if env.language == null
    res.json
      status: "failure"
      reason: "No language provided"

  if env.entrypoint == null
    res.json
      status: "failure"
      reason: "No entrypoint provided"

  if env.files == null
    res.json
      status: "failure"
      reason: "No files provided"

  container.createVolume env.files, (err, volume) ->
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