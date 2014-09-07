fs     = require "fs"
path   = require "path"
{exec} = require "child_process"

option "-t", "--test [TEST]", "a test to run"

task "test", "run all tests or a specified test", (options) ->
  mocha = "./node_modules/.bin/mocha
    --compilers coffee:coffee-script/register
    --require coffee-script 
    --colors"
  
  exec "NODE_ENV=test", ->
    exec mocha, (err, output) ->
      console.log err if err
      console.log output

task "build", "compile all dependencies", (options) -> 
  docker = "docker build -t runner ./docker"

  exec "NODE_ENV=build", ->
    exec docker, (err, output) ->
      console.log err if err
      console.log output