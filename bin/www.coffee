app     = require "../app"
winston = require "winston"

app.set "port", process.env.PORT or 3000

server = app.listen app.get("port"), ->
  winston.info "Server listening on port " + server.address().port