process.env.NODE_ENV = "test"
app = require "../app/app"

# Require HTTP testing modules
request = require "supertest"
should = require "should"

describe "POST /snippet/run with invalid language", ->
  it "should return 406 and status fail", (done) ->
    request(app)
      .post "/snippet/run"
      .send
        language: "foobarbaz"
        contents: "quxrubberdux"
      .end (err, res) ->
        should.not.exist err
        res.status.should.equal 406
        res.body.status.should.equal "failure"
        done()