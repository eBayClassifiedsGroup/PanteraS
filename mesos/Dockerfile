FROM paas
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get -y update \
    && apt-get -y install \
      mesos \
      marathon \
      chronos
