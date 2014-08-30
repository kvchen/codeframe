var express = require('express');
var swig = require('swig');
var dockerode = require('dockerode');
var docker = new dockerode({socketPath: '/var/run/docker.sock'});


// Create an instance of the Node app
var app = express();

app.engine('html', swig.renderFile);
app.use(express.static(__dirname + '/public'));

app.set('view engine', 'html');
app.set('views', __dirname + '/views');


// Define routes
var auth = require(__dirname + '/routes/auth')
var environment = require(__dirname + '/routes/environment')

app.post('/auth/token', auth.token);
app.post('/environment/run', environment.run);


// Start the server
var server = app.listen(3000);
console.log('Listening on port %d', server.address().port);