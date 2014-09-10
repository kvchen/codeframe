module.exports = 
  image: "runner"
  languages: ["python", "python2", "python3", "scheme", "logic", "ruby", "c"]
  disableNetwork: true
  memory: 50e6
  timeout: 1e4
  maxLength: 1e3
  volumes:
    code: "/opt/code"
    env: "/opt/env"
  output:
    stdout: true
    stderr: true
