# Simplest web app ever

FROM python:alpine

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN apk update && apk add bash curl
RUN mkdir -p /opt/web/cgi-bin
WORKDIR /opt/web
ENV HOME  /opt/web

ADD ./index.html /opt/web/
ADD ./cgi-bin/index /opt/web/cgi-bin/
RUN chmod a+x /opt/web/cgi-bin/index 

ADD https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh /usr/local/bin/start.sh
RUN chmod +rx /usr/local/bin/start.sh

RUN addgroup -g 31337 ecgapp && \
    adduser  -G ecgapp -u 31337 -h /app -s /bin/false -D ecgapp && \
    chown ecgapp:ecgapp /opt/web/

USER ecgapp

WORKDIR /app

ENTRYPOINT ["/usr/local/bin/start.sh"]
