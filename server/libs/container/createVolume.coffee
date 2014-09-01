fs          = require "fs-extra"
path        = require "path"
sanitize 	= require "sanitize-filename"
uuid        = require "node-uuid"

module.exports = (files, cb) ->
	basePath = path.dirname(require.main.filename)
	volume = path.join basePath, 'uploads', uuid.v4()
	fs.ensureDir volume, (err) ->
		unwrittenFileCount = files.length
		for file in files
			filename = sanitize file.name
			fs.writeFile path.join(volume, filename), file.code, (err) ->
				unwrittenFileCount--
				cb(null, volume) if unwrittenFileCount == 0