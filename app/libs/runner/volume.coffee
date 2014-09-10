async    = require "async"
fs       = require "fs-extra"
Joi      = require "joi"
path     = require "path"
sanitize = require "sanitize-filename"
winston  = require "winston"
uuid     = require "node-uuid"

createVolume = (files, cb) ->
  envUUID = uuid.v4()

  basePath = path.dirname require.main.filename
  volume = path.join basePath, "tmp", envUUID

  fileSchema = Joi.object().keys
    name: Joi.string().regex(/^[\w\-. ]+$/).required()
    contents: [
      Joi.string()
      Joi.array()
    ]

  writeVolume volume, 0, files, fileSchema, (err) ->
    return cb err if err
    cb null, volume


writeVolume = (dir, depth, files, fileSchema, cb) ->
  fs.mkdirs dir, (err) ->
    return cb new Error "Unable to create directory #{dir}" if err
    return cb new Error "Maximum path depth exceeded" if depth > 10

    async.map files, (file, cb) ->
      Joi.validate file, fileSchema, (err, value) ->
        return cb err if err

        if file.contents instanceof Array
          writeVolume path.join(dir, file.name), depth+1, file.contents, (err) ->
            return cb err if err
            cb null, null
        else
          fs.writeFile path.join(dir, file.name), file.contents, (err) ->
            return cb err if err
            cb null, null
    , (err, results) ->
      return cb new Error "Unable to write files" if err
      cb null

module.exports.createVolume = createVolume