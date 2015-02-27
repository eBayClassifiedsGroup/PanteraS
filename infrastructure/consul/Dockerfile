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

ENV HOME /opt/consul

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD consul_wan_joiner.sh /opt/consul/consul_wan_joiner.sh

ENTRYPOINT [ "supervisord" ]
