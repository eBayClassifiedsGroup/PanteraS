FROM progrium/busybox

MAINTAINER Wojciech Sielski <wsielski@team.mobile.de>

RUN opkg-install curl bash ca-certificates
RUN mkdir -p /usr/local/bin/
RUN cd /usr/local/bin/ && curl -k -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/openwrt-busybox
ENV HOME /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
