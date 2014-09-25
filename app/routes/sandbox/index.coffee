run = require "./run"

exports.index = (req, res) ->
  res.render 'sandbox'

exports.run = run