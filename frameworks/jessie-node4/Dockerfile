FROM node:4.2.2-slim

MAINTAINER Robert Schumann <roschumann@team.mobile.de>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
  && apt-get install -y curl \
  && apt-get clean

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/jessie-node4
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
