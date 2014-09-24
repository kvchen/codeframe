Codeframe
==========

[![Build Status](https://travis-ci.org/kvchen/codeframe.svg?branch=master)](https://travis-ci.org/kvchen/codeframe)

## Overview

[Codeframe](http://codefra.me) is a web platform designed to run arbitrary code in a semi-secure manner. It utilizes Docker in order to jail code execution containers and prevent code from interacting with the host.


## API

Codeframe provides a simple REST API for accessing features.


### Execution

Allows users to run both short code snippets and longer, more comprehensive code environments.

| Resource | Description |
| -------- | ----------- |
| POST /sandbox/run | Runs a sandbox environment specified by language, entrypoint, and a series of JSON-encoded files and folders. |


### Authentication (In-progress)

Codeframe will use OAuth2 for authentication, allowing users to access the API on an application basis.

| Resource | Description |
| -------- | ----------- |
| POST /oauth/token | |
| POST /oauth/invalidate_token | |


## Installation

1. Run `grunt` to compile all assets
2. Run `npm install` to install all Node dependencies
3. Run `npm start` to start the server


## Special Thanks

* [Sumukh Sridhara](https://github.com/Sumukh) for providing hosting!
