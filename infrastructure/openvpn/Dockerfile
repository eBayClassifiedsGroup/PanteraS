# Leaner build then Ubunutu
FROM paas

RUN apt-get update && \
    apt-get -y build-dep pam && \
    apt-get install -y \
      openvpn \
      iptables \
      nslcd \
      nscd

# Temporal fix for PAM in container
RUN export CONFIGURE_OPTS=--disable-audit && \
    cd /root && \
    apt-get -b source pam && \
    dpkg -i libpam-doc*.deb libpam-modules*.deb libpam-runtime*.deb libpam0g*.deb

VOLUME ["/etc/openvpn"]

WORKDIR /etc/openvpn

ADD supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 1194 1194/udp

ENTRYPOINT [ "supervisord" ]
