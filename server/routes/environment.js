var Docker = require('dockerode'), 
	fs = require('fs-extra'), 
	path = require('path'), 
	sanitize = require("sanitize-filename"), 
	uuid = require('node-uuid');

var docker = new Docker({socketPath: '/var/run/docker.sock'});

exports.run = function(req, res) {
	var params = req.body;
	var language = params.language, 
		entrypoint = params.entrypoint, 
		files = params.files;

	var environmentPath = path.join('uploads', uuid.v4());
	fs.ensureDirSync(environmentPath);

	var fileCount = files.length;
	for (var i = 0; i < fileCount; i++) {
		var file = files[i];
		var filename = sanitize(file.name), 
			code = file.code;

		fs.writeFile(path.join(environmentPath, filename), file.code);
	}

	// Possible race condition between writing the file and starting the container

	var containerOptions = {
		Image: 'runner', 
		DisableNetwork: true,
		Cmd: [language, path.join('/opt', 'code', entrypoint)], 
		Volumes: {
			'/opt/code': {}
		}
	}

	var attachOptions = {
		stream: true, 
		stdout: true, 
		stderr: true, 
		tty: false
	}

	var bindPath = path.join(path.dirname(require.main.filename), environmentPath);
	var startOptions = {
		'Binds': [bindPath + ':/opt/code']
	}

	docker.createContainer(containerOptions, function(err, container) {
		container.attach(attachOptions, function(err, stream) {
			container.start(startOptions, function(err, data) {
				var output = "";

				stream.on('data', function(chunk) {
					output += chunk.toString();
				});

				stream.on('end', function() {
					res.send(output);
					fs.remove(environmentPath);	// Race condition here
				});
			});
		});
	});
};