process.env.NODE_ENV = "test"

app     = require "../app"
request = require "supertest"
should  = require "should"

# All tests involving running containers have been disabled

ENDPOINT = "/api/environment/run"

describe "POST /api/environment/run with invalid language", ->
  it "should return 400 and status fail", (done) ->
    envInvalidLanguage = require "./requests/env_invalid_language.json"
    request(app)
      .post ENDPOINT
      .send envInvalidLanguage
      .end (err, res) ->
        should.not.exist err
        res.status.should.equal 400
        res.body.status.should.equal "failure"
        done()

describe "POST /api/environment/run with malformed files", ->
  it "should return 400 and status fail", (done) ->
    envInvalidFiles = require "./requests/env_invalid_files.json"
    request(app)
      .post ENDPOINT
      .send envInvalidFiles
      .end (err, res) ->
        should.not.exist err
        res.status.should.equal 400
        res.body.status.should.equal "failure"
        done()

describe "POST /api/environment/run with a valid environment", ->
  it "should return 200 and output execution results"

  ###
  it 'should return 200 and output results', (done) ->
    this.timeout 10000

    environmentRequest = require "./requests/valid_environment.json"
    request(app)
      .post '/api/environment/run'
      .send environmentRequest
      .end (err, res) ->
        should.not.exist err
        res.status.should.equal 200
        done()
  ###

