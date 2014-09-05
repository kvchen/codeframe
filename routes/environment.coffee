container = require "../libs/container"
config    = require "../config.json"

fs        = require "fs-extra"
Joi       = require "joi"
winston   = require "winston"

exports.run = (req, res, next) ->
  schema = Joi.object().keys
    language: Joi.valid(config.languages).required()
    entrypoint: Joi.string().required()
    files: Joi.array().includes(Joi.object()).required()

  env = req.body
  Joi.validate env, schema, (err, value) ->
    if err
      winston.warn "Malformed request: %s", err.message
      res.status(400).json
        status: "fail"
        message: err.message
    else
      container.createVolume env.files, (err, volume) ->
        if err
          winston.error "Failed to create file volume: %s", err.message
          res.status(400).json
            status: "fail"
            message: err.message
        else
          container.run env.language, env.entrypoint, volume, (err, exitCode, output) ->
            if err
              res.status(500).json
                status: "fail"
                message: err.message
            else
              res.status(200).json
                status: "success"
                data:
                  exitCode: exitCode
                  output: output

            fs.remove volume, (err) ->
              if err
                winston.error "Failed to remove directory %s", volume


