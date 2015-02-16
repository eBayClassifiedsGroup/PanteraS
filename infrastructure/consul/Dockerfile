FROM paas
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul && mkdir /etc/consul.d/
ENV PATH $PATH:/opt/consul
WORKDIR /opt/consul

# Install Consul
RUN . /opt/versions.conf \
    && wget https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_linux_amd64.zip \
    && wget https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_web_ui.zip \
    && wget https://github.com/hashicorp/envconsul/releases/download/v${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.tar.gz \
    && unzip ${CONSUL_VERSION}_linux_amd64.zip \
    && unzip ${CONSUL_VERSION}_web_ui.zip \
    && tar zxf envconsul_${ENVCONSUL_VERSION}_linux_amd64.tar.gz \
    && ln -s envconsul_${ENVCONSUL_VERSION}_linux_amd64/envconsul .

RUN echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9
RUN gpg --keyserver keyserver.ubuntu.com --recv D8576A8BA88D21E9 && gpg --export --armor D8576A8BA88D21E9 | apt-key add -
RUN . /opt/versions.conf \
    && apt-get update \
    && apt-get install -y lxc-docker-${DOCKER_VERSION}

ENV HOME /opt/consul

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD consul_wan_joiner.sh /opt/consul/consul_wan_joiner.sh
ADD check-http /opt/consul/check-http

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT [ "supervisord" ]
