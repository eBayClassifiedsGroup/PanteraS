FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN apt-get update && \
    apt-get install -y dnsmasq dnsutils

VOLUME ["/etc/openvpn"]

WORKDIR /opt

ADD supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 53 53/udp

ENTRYPOINT [ "supervisord" ]
