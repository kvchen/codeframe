express 	= require "express"
bodyParser 	= require "body-parser"
passport	= require "passport"
winston 	= require "winston"


# Define the Express app
app = express()

app.use express.static(__dirname + '/public')
app.use bodyParser.json()


# Define route endpoints
environment = require "./routes/environment"
app.post '/api/environment/run', environment.run

module.exports = app