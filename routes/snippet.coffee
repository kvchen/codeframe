runner    = require "../libs/runner"
languages = require "../config/languages.json"

Joi       = require "joi"
winston   = require "winston"

exports.run = (req, res, next) ->
  schema = Joi.object().keys
    language: Joi.valid(languages).required()
    contents: Joi.string().required()

  env = req.body
  Joi.validate env, schema, (err, value) ->
    if err
      winston.warn "Malformed request: %s", err.message
      res.status(406).json
        status: "failure"
        message: err.message
    else
      snippet = [
        name: "snippet"
        contents: env.contents
      ]
      runner.createVolume snippet, (err, volume) ->
        if err
          winston.error "Failed to create file volume: %s", err.message
          res.status(500).json
            status: "failure"
            message: err.message
        else
          runner.run env.language, "snippet", volume, (err, data) ->
            if err
              res.status(500).json
                status: "failure"
                message: err.message
            else
              res.status(200).json
                status: "success"
                data: data