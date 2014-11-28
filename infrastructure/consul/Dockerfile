FROM paas
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul && mkdir /etc/consul.d/
ENV HOME /opt/consul
ENV GOPATH /.go

ENV PATH $PATH:/opt/consul
WORKDIR /opt/consul

# Install Consul
RUN apt-get update \
    && wget https://dl.bintray.com/mitchellh/consul/0.4.0_linux_amd64.zip \
    && wget https://dl.bintray.com/mitchellh/consul/0.4.0_web_ui.zip \
    && unzip 0.4.0_linux_amd64.zip \
    && unzip 0.4.0_web_ui.zip

# Install Go
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install golang git \
    && go get -u github.com/hashicorp/envconsul \
    && cp /.go/bin/envconsul .

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD consul_wan_joiner.sh /opt/consul/consul_wan_joiner.sh

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT [ "supervisord" ]
