Codeframe
==========

[![Build Status](https://travis-ci.org/kvchen/codeframe.svg?branch=master)](https://travis-ci.org/kvchen/codeframe)

## Overview

[Codeframe](http://codefra.me) is a web platform designed to run arbitrary code in a semi-secure manner. It utilizes Docker in order to jail code execution containers and prevent code from interacting with the host.


## API

Codeframe provides a simple REST API for accessing product features.


### Execution

Allows users to run both short code snippets and longer, more comprehensive code environments.

| Resource | Description |
| -------- | ----------- |
| POST /snippet/run | Runs a snippet specified by language and contents. |
| POST /code/run | Runs an environment specified by language, entrypoint, and a series of JSON-encoded files and folders. |


### Problems and Autograder (In-progress)

Allows users to view problems, submit their answers, and view feedback.

| Resource | Description |
| -------- | ----------- |
| GET /problems/:id | Returns a single problem, specified by the id parameter. |
| POST /problems/check/:id | Submits code to the server for autograding. Returns the results of the autograder. |


### Authentication (In-progress)

Codeframe will use OAuth2 for authentication, allowing users to access the API on an application basis.

| Resource | Description |
| -------- | ----------- |
| POST /oauth/token | |
| POST /oauth/invalidate_token | |


## Installation

1. Run `cake build` to build a local copy of the Docker image
4. Run `npm install` to install all dependencies
5. Run `npm start` to start the server


## Special Thanks

* [Sumukh Sridhara](https://github.com/Sumukh) for providing hosting!
