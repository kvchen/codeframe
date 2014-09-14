express    = require "express"
bodyParser = require "body-parser"

logger = require "./libs/logger"
routes = require "./routes"

# Define the Express app
app = express()

app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/views"
app.set "view engine", "jade"

app.disable "x-powered-by"

app.use express.static __dirname + "/public/dist"
app.use bodyParser.json()


# Define view endpoints
app.get '/', routes.index


# Define API endpoints
app.post '/code/run', routes.code.run
app.post '/snippet/run', routes.snippet.run


# Export app for other modules to use
module.exports = app