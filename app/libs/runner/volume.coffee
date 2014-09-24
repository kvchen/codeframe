async    = require "async"
fs       = require "fs-extra"
Joi      = require "joi"
path     = require "path"
uuid     = require "node-uuid"
winston  = require "winston"


# Specify a schema for each object in the file array
fileSchema = Joi.object().keys
  name: Joi.string().regex(/^[\w\-. ]+$/).required()
  contents: [Joi.string(), Joi.array()]


createVolume = (files, dir, cb) ->
  writeFiles files, dir, 0, fileSchema, (err) ->
    return cb err if err
    cb null


removeVolume = (dir, cb) ->
  fs.remove dir, (err) ->
    return cb err if err
    cb null


writeFiles = (files, dir, depth, fileSchema, cb) ->
  fs.mkdirs dir, (err) ->
    return cb new Error "Unable to create directory #{dir}" if err
    return cb new Error "Maximum path depth exceeded" if depth > 10

    async.map files, (file, cb) ->
      Joi.validate file, fileSchema, (err, value) ->
        return cb err if err

        # If the contents of our file are more files, treat it like a folder
        if file.contents instanceof Array
          writeFiles path.join(dir, file.name), depth+1, file.contents, (err) ->
            return cb err if err
            cb null, null

        # Otherwise, write the contents of the file as a file
        else
          fs.writeFile path.join(dir, file.name), file.contents, (err) ->
            return cb err if err
            cb null, null
    , (err, results) ->
      return cb new Error "Unable to write files" if err
      cb null


exports.create = createVolume
exports.remove = removeVolume