Runner = require "../../libs/runner"
config = require "../../config"

Joi = require "joi"
logger = require "winston"

runnerConfig = config.docker.runner

exports.run = (req, res, next) ->
  schema = Joi.object().keys
    language: Joi.valid(runnerConfig.languages).required()
    entrypoint: Joi.string().required()
    files: Joi.array().includes(Joi.object()).required()

  env = req.body
  Joi.validate env, schema, (err, value) ->
    if err
      logger.warn "Malformed request: #{err.message}"
      res.status(406).json
        status: "failure"
        message: err.message
    else
      arbiter = new Runner env.language, env.entrypoint, env.files
      
      arbiter.run (err, output) ->
        if err
          logger.error "Failed to run code: #{err.message}"
          res.status(500).json
            status: "failure"
            message: err.message
        else
          res.status(200).json
            status: "success"
            data: output

        return arbiter.clean()

exports.index = (req, res) ->
  res.render 'sandbox'