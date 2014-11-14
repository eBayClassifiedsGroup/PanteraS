FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul_haproxy
RUN mkdir -p /opt/haproxy/mount

ENV HOME /opt/consul_haproxy
ENV GOPATH /.go
WORKDIR /opt/consul_haproxy

RUN sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    haproxy=1.5.3-1~ubuntu14.04.1 \
    golang \
    git

# HAproxy
RUN sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
    && rm -rf /var/lib/apt/lists/*

# consul-haproxy
RUN go get -u github.com/hashicorp/consul-haproxy \
    && cp /.go/bin/consul-haproxy .

# Add files
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD haproxy.sh /opt/haproxy/haproxy.sh
ADD in.conf /opt/consul_haproxy/in.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

# source https://github.com/mesosphere/marathon/blob/master/bin/haproxy-marathon-bridge
ADD haproxy-marathon-bridge /opt/haproxy/haproxy-marathon-bridge
ADD haproxy-marathon-bridge-wrapper.sh /opt/haproxy/haproxy-marathon-bridge-wrapper.sh

# Define mountable directories.
VOLUME ["/haproxy-override"]

# superviser http gui
EXPOSE 9001

# haproxy ports
EXPOSE 80
EXPOSE 81

ENTRYPOINT [ "supervisord" ]
