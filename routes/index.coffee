code = require "./code"
snippet = require "./snippet"

exports.code = code
exports.snippet = snippet

exports.index = (req, res) ->
  res.render 'index'