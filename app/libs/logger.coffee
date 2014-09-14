logger = require "winston"

if process.env.NODE_ENV is 'test'
  logger.remove logger.transports.Console

module.exports = logger