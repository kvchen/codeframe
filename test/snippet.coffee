process.env.NODE_ENV = "test"
app = require "../app"

# Require HTTP testing modules
request = require "supertest"
should = require "should"

