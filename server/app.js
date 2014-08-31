var express = require('express'), 
	bodyParser = require('body-parser'), 
	passport = require('passport'), 
	swig = require('swig');


// Create servers for both the app and the API
var app = express();
app.engine('html', swig.renderFile);
app.use(express.static(__dirname + '/public'));

app.set('view engine', 'html');
app.set('views', './views');


var api = express();
api.use(bodyParser.json());


// Define routes
var auth = require('./routes/auth')
var environment = require('./routes/environment')

api.post('/api/auth/token', auth.token);
api.post('/api/environment/run', environment.run);


// Start the server
var server = app.listen(8080);
console.log('Main server listening on port %d', server.address().port);

var apiServer = api.listen(8081);
console.log('API server listening on port %d', apiServer.address().port);