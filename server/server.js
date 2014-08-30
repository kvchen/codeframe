var express = require('express'), 
	bodyParser = require('body-parser'), 
	logger = require('morgan'), 
	passport = require('passport'), 
	swig = require('swig'), 
	dockerode = require('dockerode');


// Create servers for both the app and the API
var app = express();
var api = express();

app.engine('html', swig.renderFile);
app.use(express.static(__dirname + '/public'));

app.set('view engine', 'html');
app.set('views', './views');


// Define routes
var auth = require('./routes/auth')
var environment = require('./routes/environment')

api.post('/auth/token', auth.token);
api.post('/environment/run', 
	passport.authenticate('bearer', { session: false }), 
	environment.run);


// Start the server
var server = app.listen(3000);
console.log('Listening on port %d', server.address().port);