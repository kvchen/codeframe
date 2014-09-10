runner = require "../libs/runner"
config = require "../config"

Joi     = require "joi"
logger = require "winston"

exports.run = (req, res, next) ->
  schema = Joi.object().keys
    language: Joi.valid(config.runner.languages).required()
    entrypoint: Joi.string().required()
    files: Joi.array().includes(Joi.object()).required()

  env = req.body
  Joi.validate env, schema, (err, value) ->
    if err
      logger.warn "Malformed request: %s", err.message
      res.status(406).json
        status: "failure"
        message: err.message
    else
      runner.createVolume env.files, (err, volume) ->
        if err
          logger.error "Failed to create temporary volume: %s", err.message
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