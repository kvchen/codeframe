express    = require "express"

bodyParser = require "body-parser"
passport   = require "passport"
winston    = require "winston"

routes = require "./routes"

# Remove logging for tests
winston.remove winston.transports.Console if process.env.NODE_ENV is 'test'


# Define the Express app
app = express()

app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

app.disable "x-powered-by"

app.use express.static __dirname + "/public"
app.use bodyParser.json()


# Define view endpoints
app.get '/', routes.index


# Define API endpoints
app.post '/code/run', routes.code.run
app.post '/snippet/run', routes.snippet.run


module.exports = app