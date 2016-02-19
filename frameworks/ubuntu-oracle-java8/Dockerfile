FROM ubuntu:14.04

MAINTAINER Wojciech Sielski <wsielski@team.mobile.de>

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && apt-get clean
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN apt-get update \
    && apt-get -y install software-properties-common wget curl \
    && add-apt-repository ppa:webupd8team/java

RUN apt-get update \
    && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
    && apt-get -y install oracle-java8-installer \
    && apt-get clean \
    && update-alternatives --display java \
    && echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment \
    && echo '# /lib/init/fstab: cleared out for bare-bones lxc' > /lib/init/fstab \
    && ln -sf /proc/self/mounts /etc/mtab

RUN cd /usr/local/bin/ \
    && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh \
    && chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/ubuntu-oracle-java8
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
