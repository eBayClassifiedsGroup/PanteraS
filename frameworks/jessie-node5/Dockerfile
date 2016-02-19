FROM node:5.1.0-slim

MAINTAINER Wojciech Sielski <wsielski@team.mobile.de>

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/jessie-node5
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
