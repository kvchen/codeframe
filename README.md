Codeframe
==========

## Overview

[Codeframe](http://codefra.me) is a web platform designed to run arbitrary code in a semi-secure manner. It utilizes Docker in order to jail code execution containers and prevent code from interacting with the host.


## API

Codeframe provides a simple REST API for accessing product features.

### Authentication

Codeframe will use OAuth2 (not yet implemented) for authentication, allowing users to access the API on an application basis.

| Resource | Description |
| -------- | ----------- |
| POST /oauth2/request_token | |
| POST /oauth2/invalidate_token | |


### Execution

Allows users to run both short code snippets and longer, more comprehensive code environments.

| Resource | Description |
| -------- | ----------- |
| POST /api/snippet/run | Runs a snippet specified by language and contents. |
| POST /api/environment/run | Runs an environment specified by language, entrypoint, and a series of JSON-encoded files and folders. |


## Installation

1. Navigate to the `/container` directory
2. Run `docker build -t runner .`
3. Go to the `/server` directory
4. Run `npm install` to install all dependencies
5. Run `npm start` to start the server


## Special Thanks

* [Sumukh Sridhara](https://github.com/Sumukh)
