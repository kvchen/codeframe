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
app.get  '/sandbox', routes.sandbox.index
app.post '/sandbox/run', routes.sandbox.run

###
app.get  '/sandbox/load/', routes.sandbox.load

app.post '/snippet/create', routes.snippet.create
app.get  '/snippet/:id', routes.snippet.load

app.get '/courses', routes.course.index
app.get '/courses/:courseId', routes.course.course
app.get '/courses/:courseId/sections', routes.course.section.index
app.get '/courses/:courseId/sections/:sectionId', routes.course.section.section
app.get '/courses/:courseId/sections/:sectionId/exercises', routes.course.exercise.index
app.get '/courses/:courseId/sections/:sectionId/exercises/:exerciseId', routes.course.exercise.exercise
###


# Export app for other modules to use
module.exports = app