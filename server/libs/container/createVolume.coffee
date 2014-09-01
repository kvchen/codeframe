fs          = require "fs-extra"
path        = require "path"
sanitize 	= require "sanitize-filename"
uuid        = require "node-uuid"

module.exports = (files, cb) ->
	basePath = path.dirname(require.main.filename)
	volume = path.join basePath, 'uploads', uuid.v4()
	fs.ensureDirSync(volume)

	for file in files
		filename = sanitize file.name
		fs.writeFileSync path.join(volume, filename), file.code

	cb(null, volume)