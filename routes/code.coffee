runner    = require "../libs/runner"
languages = require "../config/languages.json"

Joi       = require "joi"
winston   = require "winston"

exports.run = (req, res, next) ->
  schema = Joi.object().keys
    language: Joi.valid(languages).required()
    entrypoint: Joi.string().required()
    files: Joi.array().includes(Joi.object()).required()

  env = req.body
  Joi.validate env, schema, (err, value) ->
    if err
      winston.warn "Malformed request: %s", err.message
      res.status(406).json
        status: "failure"
        message: err.message
    else
      runner.createVolume env.files, (err, volume) ->
        if err
          winston.error "Failed to create temporary volume: %s", err.message
          res.status(500).json
            status: "failure"
            message: "Failed to create temporary volume"
        else
          runner.run env.language, env.entrypoint, volume, (err, data) ->
            if err
              res.status(500).json
                status: "failure"
                message: err.message
            else
              res.status(200).json
                status: "success"
                data: data