FROM ubuntu:14.04
MAINTAINER Kevin Chen <kvchen@berkeley.edu>

RUN apt-get update
RUN apt-get install -y python python3 racket
RUN racket -p dyoo/simply-scheme:2:2

ADD entrypoint.sh entrypoint.sh
ADD run.sh run.sh
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
