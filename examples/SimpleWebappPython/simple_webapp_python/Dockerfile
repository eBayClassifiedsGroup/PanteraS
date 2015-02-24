# Simplest web app ever

FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir -p /opt/web/cgi-bin
WORKDIR /opt/web
ENV HOME  /opt/web

ADD ./index.html /opt/web/
ADD ./cgi-bin/index /opt/web/cgi-bin/
RUN chmod a+x /opt/web/cgi-bin/index 

ADD ./start.sh /opt/web/
RUN chmod a+x /opt/web/start.sh

EXPOSE 8000

ENTRYPOINT [ "/bin/bash", "-c", "/opt/web/start.sh" ]
