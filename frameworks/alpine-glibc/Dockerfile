FROM alpine:3.2

MAINTAINER Wojciech Sielski <wsielski@team.mobile.de>

RUN apk --update add curl bash ca-certificates

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/alpine-glibc
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
