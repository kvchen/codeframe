express    = require "express"
bodyParser = require "body-parser"
passport   = require "passport"
winston    = require "winston"

if process.env.NODE_ENV is 'test'
  winston.remove winston.transports.Console


# Define the Express app
app = express()

app.use express.static(__dirname + '/public')
app.use bodyParser.json()

# Initialize templating engine
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'


# Define view endpoints
app.get '/', (req, res) ->
  res.render 'index'

# Define API endpoints
auth = require "./routes/auth"

environment = require "./routes/environment"
app.post '/api/environment/run', environment.run

module.exports = app