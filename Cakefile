fs     = require "fs"
path   = require "path"
{exec} = require "child_process"

REPORTER = "nyan"

option "-t", "--test [TEST]", "a test to run"

task "test", "run all tests or a specified test", (options) ->
  mocha = "./node_modules/.bin/mocha
    --compilers coffee:coffee-script/register
    --reporter #{REPORTER}
    --require coffee-script 
    --require test/helpers/assert_helper.coffee
    --colors"
  
  exec "NODE_ENV=test", ->
    exec mocha, (err, output) ->
      console.log err if err
      console.log output
