var express = require('express'), 
	bodyParser = require('body-parser'), 
	passport = require('passport'), 


// Create servers for both the app and the API
var app = express();
app.use(express.static(__dirname + '/public'));

app.set('view engine', 'html');
app.set('views', './views');
app.use(bodyParser.json());


// Define routes
var auth = require('./routes/auth')
var environment = require('./routes/environment')


// Define API routes
app.post('/api/auth/token', auth.token);
app.post('/api/environment/run', environment.run);


// Start the server
var server = app.listen(8080);
console.log('Main server listening on port %d', server.address().port);