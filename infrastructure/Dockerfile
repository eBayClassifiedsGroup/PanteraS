# PanteraS
# Platform as a Service based on Paas in a box project
#
FROM ubuntu:16.04

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN apt-get update \
    && apt-get install -y \
      locales \
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
      jshon \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM xterm
ENV HOME /root
ENV GOPATH ${HOME}/go

ENV SUPERVISORD_APP_VERSION       3.3.3
ENV DOCKER_APP_VERSION            5:18.09.3~3-0~ubuntu-xenial
ENV CONSUL_APP_VERSION            1.4.3
ENV MESOS_APP_VERSION             1.7.1-2.0.1
ENV MARATHON_APP_VERSION          1.7.189-0.1.20190125223314.ubuntu1604
ENV REGISTRATOR_APP_VERSION       v7
ENV FABIO_APP_VERSION             1.5.11
ENV FABIO_GO_APP_VERSION          go1.11.5
ENV NETDATA_APP_VERSION           1.12.2

ENV DOCKER_HOST unix:///tmp/docker.sock


# SupervisorD
#
RUN pip install --upgrade pip
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

# ZOOKEEPER MESOS MARATHON
#
RUN echo "deb http://repos.mesosphere.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/mesosphere.list \
    # marathon postinstall fix, since we we dont need systemctl
    && ln -sf /bin/true  /bin/systemctl \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv DF7D54CBE56151BF \
    && apt-get update \
    # marathon still build against java8
    && apt-get -y install \
       openjdk-8-jre \
       mesos=${MESOS_APP_VERSION} \
       marathon=${MARATHON_APP_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/mesos/zk \
    && ln -s /usr/share/marathon/bin/marathon /usr/local/bin/
ADD zkStart.sh /opt/zkStart.sh

# DOCKER
#
RUN echo 'deb https://download.docker.com/linux/ubuntu xenial stable' > /etc/apt/sources.list.d/docker.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0EBFCD88 \
    && apt-get update \
    && apt-get install -y docker-ce=${DOCKER_APP_VERSION} \
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
RUN wget https://github.com/eBay/fabio/releases/download/v${FABIO_APP_VERSION}/fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}-linux_amd64 \
    && chmod a+x fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}-linux_amd64 \
    && ln -s fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}-linux_amd64 fabio

# NETDATA

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
    && git clone -b v${NETDATA_APP_VERSION} --single-branch https://github.com/netdata/netdata.git /tmp/netdata.git --depth=1 \
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

ADD panteras.http      /etc/fabio/errors/
ADD fabio.properties   /opt/fabio/fabio.properties

ADD logo.sh            /etc/profile.d
ADD paas.sh            /etc/profile.d
ADD bashrc             /tmp
ADD version            /opt/

# example user
RUN groupadd -g 31337 ecgapp && \
    useradd  -g 31337 -u 31337 -d /app -s /bin/false ecgapp

RUN cat /tmp/bashrc >> /root/.bashrc

WORKDIR /opt
CMD [ "/opt/supervisord.sh" ]
