FROM alpine:3.6

MAINTAINER Rick Rackow <rrackow@team.mobile.de>

RUN apk --update add curl bash ca-certificates openjdk8

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/alpine-openjdk8
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
