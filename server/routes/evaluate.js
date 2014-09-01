var Docker = require('dockerode'), 
	fs = require('fs-extra'), 
	path = require('path'), 
	winston = require('winston');

var docker = new Docker({socketPath: 'unix:///var/run/docker.sock'});
winston.info('Docker client successfully initialized');

module.exports = function(language, entrypoint, volume, cb) {
	var containerOptions = {
		Image: 'runner', 
		DisableNetwork: true,
		Cmd: [language, path.join('/opt/code', entrypoint)], 
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

	var startOptions = {
		Binds: [volume + ':/opt/code']
	}

	docker.createContainer(containerOptions, function(err, container) {
		container.attach(attachOptions, function(err, stream) {
			stream.setEncoding('utf-8');
			container.start(startOptions, function(err, data) {
				var output = "";

				stream.on('data', function(chunk) {
					output += chunk.toString();
				});

				stream.on('end', function() {
					fs.remove(volume);	// Race condition here
					cb(output);
				});
			});
		});
	});

}