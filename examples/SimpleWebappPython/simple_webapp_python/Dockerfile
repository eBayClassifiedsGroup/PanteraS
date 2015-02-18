# Simplest web app ever

FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list
RUN gpg --keyserver  hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9 && gpg --export --armor D8576A8BA88D21E9 | apt-key add -
RUN . /opt/versions.conf \
    && apt-get update \
    && apt-get install -y lxc-docker-${DOCKER_VERSION}

RUN mkdir -p /opt/web/cgi-bin
ENV HOME  /opt/web
WORKDIR /opt/web

ADD ./index.html /opt/web/
ADD ./cgi-bin/index /opt/web/cgi-bin/
RUN chmod a+x /opt/web/cgi-bin/index 

ADD ./register.tmpl /opt/web/
ADD ./register_and_start.sh /opt/web/
ADD ./start.sh /opt/web/
RUN chmod a+x /opt/web/register_and_start.sh
RUN chmod a+x /opt/web/start.sh

EXPOSE 8000

ENTRYPOINT [ "/bin/bash", "-c", "/opt/web/start.sh" ]
