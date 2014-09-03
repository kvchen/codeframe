codefra.me
==========

## Overview

**Codefra.me** (formerly Arbiter) is a web platform designed to run arbitrary code in a semi-secure manner. It utilizes Docker's resource isolation interface in order to jail code execution containers, effectively providing a runtime environment separate from the host.

## Installation

1. Navigate to the `/container` directory
2. Run `docker build -t runner .`
3. Go to the `/server` directory
4. Run `npm install` to install all dependencies
5. Run `npm start` to start the server

## Special Thanks

* [Sumukh Sridhara](https://github.com/Sumukh)
