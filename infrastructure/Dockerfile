# PanteraS
# Platform as a Service based on Paas in a box project
#
FROM ubuntu:16.04

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm
ENV HOME /root
ENV GOPATH ${HOME}/go

RUN apt-get update \
    && apt-get install -y \
       apt-transport-https \
       python-pip \
       wget \
       curl \
       unzip \
       dnsutils \
       vim \
       git \
       lolcat \
       toilet \
       keepalived \
       iptables \
       libapparmor1 \
       jshon \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV SUPERVISORD_APP_VERSION       3.2.3
ENV DOCKER_APP_VERSION            1.12.1-0~xenial
ENV CONSUL_APP_VERSION            0.7.0
ENV CONSUL_TEMPLATE_APP_VERSION   0.16.0
ENV HAPROXY_APP_VERSION           1.6.3-1ubuntu0.1
ENV MESOS_APP_VERSION             1.0.1-2.0.94.ubuntu1604
ENV MARATHON_APP_VERSION          1.3.2-1.0.525.ubuntu1604
ENV REGISTRATOR_APP_VERSION       v7
ENV CHRONOS_APP_VERSION           2.4.0-0.1.20151007110204.ubuntu1404
ENV FABIO_APP_VERSION             1.3.2
ENV FABIO_GO_APP_VERSION          go1.7.1

ENV DOCKER_HOST unix:///tmp/docker.sock

# SupervisorD
#
RUN pip install supervisor-stdout
RUN pip install https://github.com/Supervisor/supervisor/archive/${SUPERVISORD_APP_VERSION}.zip


# CONSUL
#
RUN mkdir -p /opt/consul/data && mkdir /etc/consul.d/
ENV PATH $PATH:/opt/consul
WORKDIR /opt/consul

RUN wget https://releases.hashicorp.com/consul/${CONSUL_APP_VERSION}/consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && unzip consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && rm consul_*.zip

# DNSMASQ
#
RUN apt-get update \
    && apt-get install -y dnsmasq dnsutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# HAPROXY
#
RUN mkdir /opt/consul-template
ENV PATH $PATH:/opt/consul-template
WORKDIR /opt/consul-template

RUN sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
       haproxy=${HAPROXY_APP_VERSION} \
    && apt-get clean \
    && sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/sbin/haproxy /usr/sbin/haproxy_a \
    && ln -s /usr/sbin/haproxy /usr/sbin/haproxy_b

# consul-template
RUN wget https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_APP_VERSION}/consul-template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.zip \
    && unzip consul-template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.zip

# HAPROXY config
#
# Add files
ADD haproxy.cfg        /etc/haproxy/
ADD haproxy.pem       /etc/haproxy/
# same file for an "empty template"
ADD haproxy.cfg        /opt/consul-template/
ADD haproxy.cfg.ctmpl  /opt/consul-template/
ADD haproxy_reload.sh  /opt/consul-template/
ADD consul-template.sh /opt/consul-template/
ADD consul_config.json /etc/consul.d/

# KEEPALIVED config
#
ADD keepalived.conf.ctmpl /opt/consul-template/
ADD keepalived_reload.sh  /opt/consul-template/

# ZOOKEEPER MESOS MARATHON
#
RUN echo "deb http://repos.mesosphere.io/ubuntu/ xenial main" > /etc/apt/sources.list.d/mesosphere.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF \
    && apt-get update \
    && apt-get -y install \
       mesos=${MESOS_APP_VERSION} \
       marathon=${MARATHON_APP_VERSION} \
    && wget http://repos.mesosphere.io/ubuntu/pool/main/c/chronos/chronos_${CHRONOS_APP_VERSION}_amd64.deb \
    && dpkg -i chronos_${CHRONOS_APP_VERSION}_amd64.deb \
    && rm chronos_${CHRONOS_APP_VERSION}_amd64.deb \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/mesos/zk
ADD zkStart.sh /opt/zkStart.sh
    # Chronos no longer in mesosphere ?
    #chronos=${CHRONOS_APP_VERSION}\

# DOCKER
#
RUN echo 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' > /etc/apt/sources.list.d/docker.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv F76221572C52609D \
    && apt-get update \
    && apt-get install -y docker-engine=${DOCKER_APP_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# REGISTRATOR
#
RUN mkdir /opt/registrator
ENV PATH ${PATH}:/opt/registrator
WORKDIR /opt/registrator
# Providing binaries by us
RUN wget https://github.com/eBayClassifiedsGroup/registrator/releases/download/${REGISTRATOR_APP_VERSION}/registrator.tgz \
    && tar zxf registrator.tgz \
    && rm registrator.tgz

# FABIO
#
RUN mkdir /opt/fabio
ENV PATH ${PATH}:/opt/fabio
WORKDIR /opt/fabio
ADD fabio.properties /opt/fabio/fabio.properties
RUN wget https://github.com/eBay/fabio/releases/download/v${FABIO_APP_VERSION}/fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}_linux-amd64 \
    && chmod a+x fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}_linux-amd64 \
    && ln -s fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}_linux-amd64 fabio


# NETDATA
#
RUN apt-get update \
    && apt-get -y install \
       zlib1g-dev \
       gcc \
       make \
       autoconf \
       autogen \
       automake \
       pkg-config \
       uuid-dev \
       libmnl-dev \
    && git clone https://github.com/firehol/netdata.git /tmp/netdata.git --depth=1 \
    && cd /tmp/netdata.git \
    && ./netdata-installer.sh --dont-wait --install /opt \
    && cd /opt \
    && rm -rf /tmp/* \
    && ln -sf /dev/stdout /opt/netdata/var/log/netdata/access.log \
    && ln -sf /dev/stderr /opt/netdata/var/log/netdata/error.log \
    && apt-get -y remove \
       zlib1g-dev \
       gcc \
       make \
       autoconf \
       autogen \
       automake \
       pkg-config \
       uuid-dev \
       libmnl-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# PanteraS:
RUN gem install panteras_api marathon_deploy
# Font for logo
RUN wget https://raw.githubusercontent.com/patorjk/figlet.js/master/fonts/Elite.flf -O /usr/share/figlet/Elite.flf

ADD supervisord.conf   /etc/supervisord.conf
ADD supervisord.sh     /opt/
ADD panteras.http      /etc/haproxy/errors/
ADD version            /opt/
ADD bashrc             /tmp
RUN cat /tmp/bashrc >> /root/.bashrc

WORKDIR /opt
ENTRYPOINT [ "/opt/supervisord.sh" ]
