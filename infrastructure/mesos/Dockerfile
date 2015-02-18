FROM paas
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list

#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv E56151BF && gpg --export --armor E56151BF | apt-key add -

RUN . /opt/versions.conf \
    && apt-get update \
    && apt-get -y install \
      mesos=${MESOS_VERSION} \
      marathon=${MARATHON_VERSION}

ADD zkStart.sh /opt/zkStart.sh
