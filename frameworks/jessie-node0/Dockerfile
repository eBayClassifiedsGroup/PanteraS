FROM node:0.12.8-slim

MAINTAINER Robert Schumann <roschumann@team.mobile.de>

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/jessie-node0
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
