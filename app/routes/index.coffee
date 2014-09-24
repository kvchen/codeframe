sandbox = require "./sandbox"

module.exports.sandbox = sandbox

exports.index = (req, res) ->
  res.render 'sandbox'