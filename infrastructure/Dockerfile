# PanteraS
# Platform as a Service based on Paas in a box project
#
FROM ubuntu:14.04.4

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
   && apt-get clean

RUN pip install supervisor-stdout
RUN pip install https://github.com/Supervisor/supervisor/archive/3.2-branch.zip

# install Java 8
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > /etc/apt/sources.list.d/java-trusty.list \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv EEA14886 && gpg --export --armor EEA14886 | apt-key add - \
    && apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get -y install oracle-java8-installer \
    && apt-get clean \
    && update-alternatives --display java \
    && echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment

ENV DOCKER_APP_VERSION            1.10.2-0~trusty
ENV CONSUL_APP_VERSION            0.6.3
ENV CONSUL_TEMPLATE_APP_VERSION   0.10.0
ENV HAPROXY_APP_VERSION           1.5.14-1ubuntu0.15.10.1~ubuntu14.04.1
ENV MESOS_APP_VERSION             0.26.0-0.2.145.ubuntu1404
ENV MARATHON_APP_VERSION          0.15.3-1.0.463.ubuntu1404
ENV REGISTRATOR_APP_VERSION       v6
ENV CHRONOS_APP_VERSION           2.4.0-0.1.20151007110204.ubuntu1404
ENV FABIO_APP_VERSION             1.1.1

ENV DOCKER_HOST unix:///tmp/docker.sock


# CONSUL
#
RUN mkdir /opt/consul && mkdir /etc/consul.d/
ENV PATH $PATH:/opt/consul
WORKDIR /opt/consul

RUN wget https://releases.hashicorp.com/consul/${CONSUL_APP_VERSION}/consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && wget https://releases.hashicorp.com/consul/${CONSUL_APP_VERSION}/consul_${CONSUL_APP_VERSION}_web_ui.zip \
    && unzip consul_${CONSUL_APP_VERSION}_linux_amd64.zip \
    && unzip consul_${CONSUL_APP_VERSION}_web_ui.zip \
    && rm consul_*.zip

# DNSMASQ
#
RUN apt-get install -y dnsmasq dnsutils \
    && apt-get clean


# HAPROXY
#
RUN mkdir /opt/consul-template
ENV PATH $PATH:/opt/consul-template
WORKDIR /opt/consul-template

RUN sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    haproxy="${HAPROXY_APP_VERSION}" \
    && apt-get clean

RUN sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/sbin/haproxy /usr/sbin/haproxy_a
RUN ln -s /usr/sbin/haproxy /usr/sbin/haproxy_b

# consul-template
#RUN wget https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_APP_VERSION}/consul_template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.zip \
#   && unzip consul_template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.zip
RUN wget https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_APP_VERSION}/consul-template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.tar.gz \
    && tar zxf consul-template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64.tar.gz \
    && ln -s consul-template_${CONSUL_TEMPLATE_APP_VERSION}_linux_amd64/consul-template .

# HAPROXY config
#
# Add files
ADD haproxy.cfg        /etc/haproxy/
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
RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list

#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF && gpg --export --armor E56151BF | apt-key add -

RUN apt-get update \
    && apt-get -y install \
      mesos=${MESOS_APP_VERSION} \
      marathon=${MARATHON_APP_VERSION} \
      chronos=${CHRONOS_APP_VERSION} \
    && apt-get clean

ADD zkStart.sh /opt/zkStart.sh
RUN rm /etc/mesos/zk

#RUN echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9
#RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9 && gpg --export --armor D8576A8BA88D21E9 | apt-key add -

RUN echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv F76221572C52609D && gpg --export --armor F76221572C52609D | apt-key add -
RUN apt-get update \
    && apt-get install -y docker-engine=${DOCKER_APP_VERSION} \
    || { wget http://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_${DOCKER_APP_VERSION}_amd64.deb \
    && dpkg -i docker-engine_${DOCKER_APP_VERSION}_amd64.deb; }

# REGISTRATOR
#
RUN mkdir /opt/registrator
ENV PATH ${PATH}:/opt/registrator
WORKDIR /opt/registrator
# Binaries are not supported anymore
#  && wget https://github.com/progrium/registrator/releases/download/v${REGISTRATOR_APP_VERSION}/registrator_${REGISTRATOR_APP_VERSION}_linux_x86_64.tgz \
#  && tar zxf registrator_${REGISTRATOR_APP_VERSION}_linux_x86_64.tgz
# Providing binaries by us - temporaly
RUN wget https://github.com/eBayClassifiedsGroup/registrator/releases/download/${REGISTRATOR_APP_VERSION}/registrator.tgz \
    && tar zxf registrator.tgz

# FABIO
#
RUN mkdir /opt/fabio
ENV PATH ${PATH}:/opt/fabio
WORKDIR /opt/fabio
ADD fabio.properties /opt/fabio/fabio.properties
RUN wget https://github.com/eBay/fabio/releases/download/v${FABIO_APP_VERSION}/fabio-${FABIO_APP_VERSION}-go1.6_linux-amd64 \
    && chmod a+x fabio-${FABIO_APP_VERSION}-go1.6_linux-amd64 \
    && ln -s fabio-${FABIO_APP_VERSION}-go1.6_linux-amd64 fabio

# Font for logo
RUN wget https://raw.githubusercontent.com/patorjk/figlet.js/master/fonts/Elite.flf -O /usr/share/figlet/Elite.flf

ADD supervisord.conf   /etc/supervisord.conf
ADD supervisord.sh     /opt/
ADD panteras.http      /etc/haproxy/errors/
ADD version            /opt/

WORKDIR /opt
ENTRYPOINT [ "/opt/supervisord.sh" ]
