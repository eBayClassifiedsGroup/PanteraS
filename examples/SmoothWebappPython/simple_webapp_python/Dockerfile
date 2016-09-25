# Simplest web app ever

FROM ubuntu:16.04

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN DEBIAN_FRONTEND=noninteractive apt-get update; apt-get install -y python3 curl
RUN mkdir -p /opt/web/cgi-bin
WORKDIR /opt/web
ENV HOME  /opt/web

ADD ./index.html /opt/web/
ADD ./cgi-bin/index /opt/web/cgi-bin/
RUN chmod a+x /opt/web/cgi-bin/index 

ADD https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 8000

WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
