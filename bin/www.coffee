app     = require "../app"
winston = require "winston"

server = app.listen app.get("port"), ->
  winston.info "Server listening on port " + server.address().port