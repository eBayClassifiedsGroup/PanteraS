# PanteraS
# Platform as a Service based on Paas in a box project
#
FROM ubuntu:16.04

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN apt-get update --no-install-recommends \
    && apt-get install -y \
      locales \
      apt-transport-https \
      python3-minimal \
      python3-setuptools \
      wget \
      curl \
      unzip \
      vim-tiny \
      lolcat \
      toilet \
      jshon \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
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

ENV SUPERVISORD_APP_VERSION       4.1.0
ENV DOCKER_APP_VERSION            5:19.03.5~3-0~ubuntu-xenial
ENV CONSUL_APP_VERSION            1.6.2
ENV MESOS_APP_VERSION             1.9.0-2.0.1.ubuntu1604
#ENV MARATHON_APP_VERSION          1.9.81-0.1.20190905233136.ubuntu1604
ENV MARATHON_APP_VERSION          1.7.216-9e2a9b579
ENV REGISTRATOR_APP_VERSION       v7
ENV FABIO_APP_VERSION             1.5.13
ENV FABIO_GO_APP_VERSION          go1.13.4
ENV NETDATA_APP_VERSION           1.19.0
#ENV TRAEFIK_APP_VERSION           v2.0.0-beta1
ENV TRAEFIK_APP_VERSION           v1.7.19


ENV DOCKER_HOST unix:///tmp/docker.sock


# SupervisorD
#
RUN wget https://github.com/Supervisor/supervisor/archive/${SUPERVISORD_APP_VERSION}.zip \
    && unzip ${SUPERVISORD_APP_VERSION}.zip \
    && cd supervisor-${SUPERVISORD_APP_VERSION} \
    && python3 setup.py install \
    && cd - \
    && rm -rf ${SUPERVISORD_APP_VERSION}.zip supervisor-${SUPERVISORD_APP_VERSION}


# ZOOKEEPER MESOS MARATHON
#
RUN echo "deb http://repos.mesosphere.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/mesosphere.list \
    # marathon postinstall fix, since we we dont need systemctl
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv DF7D54CBE56151BF \
    && apt-get update \
    # marathon still build against java8
    && apt-get -y install --no-install-recommends \
       openjdk-8-jre \
       mesos=${MESOS_APP_VERSION}  \
       zookeeper \
    #  marathon=${MARATHON_APP_VERSION} \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/mesos/zk \
    && chown -R zookeeper /etc/zookeeper \
    && REAL_JAVA_PATH=$(readlink -f $(which java)) \
    && JAVA_DIR=${REAL_JAVA_PATH%/bin/java} \
    && mkdir -p ${JAVA_DIR}/conf/management/ \
    && touch ${JAVA_DIR}/conf/management/management.properties

RUN wget https://downloads.mesosphere.io/marathon/builds/${MARATHON_APP_VERSION}/marathon-${MARATHON_APP_VERSION}.tgz \
    && mkdir /opt/marathon \
    && tar -C /opt/marathon --strip 1 -zxf marathon-${MARATHON_APP_VERSION}.tgz \
    && rm marathon-${MARATHON_APP_VERSION}.tgz \
    && ln -s /opt/marathon/bin/marathon /usr/local/bin

ADD zkStart.sh /opt/zkStart.sh

# DOCKER
#
RUN echo 'deb https://download.docker.com/linux/ubuntu xenial stable' > /etc/apt/sources.list.d/docker.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0EBFCD88 \
    && apt-get update \
    && apt-get install -y docker-ce-cli=${DOCKER_APP_VERSION} \
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

# CONSUL
#
RUN mkdir -p /opt/consul/data /etc/consul.d \
    && groupadd -g 3000 consul \
    && useradd  -g 3000 -u 3000 -d /opt/consul -s /bin/false consul
ENV PATH $PATH:/opt/consul
WORKDIR /opt/consul

RUN wget https://releases.hashicorp.com/consul/${CONSUL_APP_VERSION}/consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && unzip consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && rm consul_*.zip \
    && chown -R consul:consul /opt/consul

# FABIO
#
RUN mkdir /opt/fabio \
    && groupadd -g 3001 fabio \
    && useradd  -g 3001 -u 3001 -d /opt/fabio -s /bin/false fabio
ENV PATH ${PATH}:/opt/fabio
WORKDIR /opt/fabio
RUN wget https://github.com/eBay/fabio/releases/download/v${FABIO_APP_VERSION}/fabio-${FABIO_APP_VERSION}-${FABIO_GO_APP_VERSION}-linux_amd64 -O fabio \
    && chmod a+x fabio \
    && chown -R fabio:fabio /opt/fabio \
    && setcap 'cap_net_bind_service=+ep' ./fabio

# TRAEFIK
#
RUN mkdir /opt/traefik \
    && groupadd -g 3002 traefik \
    && useradd  -g 3002 -u 3002 -d /opt/traefik -s /bin/false traefik
ENV PATH ${PATH}:/opt/traefik
WORKDIR /opt/traefik
#RUN wget https://github.com/containous/traefik/releases/download/${TRAEFIK_APP_VERSION}/traefik_${TRAEFIK_APP_VERSION}_linux_amd64.tar.gz -O traefik.tar.gz \
RUN wget https://github.com/containous/traefik/releases/download/${TRAEFIK_APP_VERSION}/traefik_linux-amd64 -O traefik \
#    && tar zxf traefik.tar.gz \
    && chmod a+x traefik \
    && chown -R traefik:traefik /opt/traefik \
    && setcap 'cap_net_bind_service=+ep' ./traefik
ADD traefik.toml /opt/traefik

# NETDATA
#
RUN savedAptMark="$(apt-mark showmanual)" \
    && apt-get update \
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
       git \
    && git clone -b v${NETDATA_APP_VERSION} --single-branch https://github.com/netdata/netdata.git /tmp/netdata.git --depth=1 \
    && cd /tmp/netdata.git \
    && ./netdata-installer.sh --dont-wait --install /opt \
    && cd /opt \
    && rm -rf /tmp/* \
    && ln -sf /dev/stdout /opt/netdata/var/log/netdata/access.log \
    && ln -sf /dev/stderr /opt/netdata/var/log/netdata/error.log \
    && apt-mark auto '.*' > /dev/null \
    && apt-mark manual $savedAptMark \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false  \
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

RUN groupadd -g 3003 marathon \
    && useradd  -g 3003 -u 3003 -d /opt/marathon -s /bin/false marathon

RUN cat /tmp/bashrc >> /root/.bashrc

WORKDIR /opt
CMD [ "/opt/supervisord.sh" ]
