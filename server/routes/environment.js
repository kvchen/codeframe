var evaluate = require('./evaluate'), 
	fs = require('fs-extra'), 
	path = require('path'), 
	sanitize = require('sanitize-filename'), 
	uuid = require('node-uuid'), 
	winston = require('winston');

exports.run = function(req, res) {
	var env = req.body;
	response = {}

	var volume = path.join(path.dirname(require.main.filename), 'uploads', uuid.v4());
	fs.ensureDirSync(volume);

	var fileCount = env.files.length;
	for (var i = 0; i < fileCount; i++) {
		var file = env.files[i];
		var filename = sanitize(file.name), 
			code = file.code;

		fs.writeFileSync(path.join(volume, filename), file.code);
	}

	// Possible race condition between writing the file and starting the container

	evaluate(env.language, env.entrypoint, volume, function(output) {
		response.success = true;
		response.output = output;
		res.json(response)
	});
};