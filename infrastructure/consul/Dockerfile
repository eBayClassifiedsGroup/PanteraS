FROM paas
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul && mkdir /etc/consul.d/
ENV HOME /opt/consul

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

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD consul_wan_joiner.sh /opt/consul/consul_wan_joiner.sh

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

ENTRYPOINT [ "supervisord" ]
