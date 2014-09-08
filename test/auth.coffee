process.env.NODE_ENV = "test"
app = require "../app"

# Require HTTP testing modules
request = require "supertest"
should = require "should"

# Require db-related modules
mongoose = require "mongoose"
userModels   = require("../models").users
mongoConfig = require "../config/mongodb.json"

mongoose.connect mongoConfig.testUri

describe "OAuth 2.0 endpoints",  ->
  beforeEach (done) ->
    newUser = new userModels.User
      username: "peterperfect" 
      password: "hunter2"

    newClient = new userModels.Client
      name: "testApplication"
      clientId: "testApp"
      clientSecret: "foobarbaz"

    newUser.save (err, user) ->
      newClient.save (err, user) ->
        done()

  afterEach (done) ->
    userModels.User.remove {}, ->
      userModels.Client.remove {}, ->
        done()

  it "should return 200 and supply both an access token and a refresh token"

