### Configuration file

This file contains all the necessary options for running an instance of
Codeframe.
###


# Database and Daemon settings

module.exports.docker = 
  socket: "/var/run/docker.sock"
  runner:
    image: "runner"
    languages: ["hog", "python", "python2", "python3", "scheme", "logic", "ruby", "c"]
    networkDisabled: true
    memory: 50e6
    timeout: 1e4
    maxLength: 1e3
    volumes:
      code: "/opt/runner/code"
      env: "/opt/runner/env"
    output:
      stream: true
      stdout: true
      stderr: true
      tty: false

module.exports.mongodb = 
  uri:
    dev: "mongodb://localhost/codeframe_dev"
    prod: "mongodb://localhost/codeframe"


# User and authentication settings 

module.exports.auth = 
  tokenLife: 3600