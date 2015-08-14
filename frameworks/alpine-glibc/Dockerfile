FROM alpine:3.2

MAINTAINER Wojciech Sielski <wsielski@team.mobile.de>

RUN apk --update add curl bash
RUN curl -O "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
  && apk add --allow-untrusted glibc-2.21-r2.apk \
  && rm -f glibc-2.21-r2.apk
RUN curl -O "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" \
  && apk add --allow-untrusted glibc-bin-2.21-r2.apk \
  && rm -f glibc-bin-2.21-r2.apk
RUN /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib

RUN cd /usr/local/bin/ && curl -O https://raw.githubusercontent.com/eBayClassifiedsGroup/PanteraS/master/frameworks/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENV IMAGE panteras/alpine-glibc
ENV HOME  /
WORKDIR /

ENTRYPOINT ["/usr/local/bin/start.sh"]
