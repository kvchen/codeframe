app    = require "./app/app"
logger = require "winston"

server = app.listen app.get("port"), ->
  logger.info "Server listening on port " + server.address().port