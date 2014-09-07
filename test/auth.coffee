process.env.NODE_ENV = "test"
app = require "../app"

# Require HTTP testing modules
request = require "supertest"
should = require "should"

# Require db-related modules
mongoose = require "mongoose"
models   = require "../models"
mongoConfig = require "../config/mongodb.json"

mongoose.connect mongoConfig.uri

describe "OAuth 2.0 endpoints",  ->

  beforeEach (done) ->
    newUser = new models.User
      username: "peterperfect" 
      password: "hunter2"

    newUser.save (err, user) ->
      return winston.error err if err
      done()

  afterEach (done) ->
    models.User.remove {}, ->
      done()

  it "should return 200 and supply both an access token and a refresh token"