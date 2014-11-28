FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul_template
RUN mkdir -p /opt/haproxy/mount

ENV HOME /opt/consul_template
ENV GOPATH /.go
WORKDIR /opt/consul_template

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
RUN go get -u github.com/hashicorp/consul-template \
    && cp /.go/bin/consul-template .

# Add files
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD in.conf /opt/consul_template/in.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Define mountable directories.
VOLUME ["/haproxy-override"]

# superviser http gui
EXPOSE 9001

# haproxy ports
EXPOSE 80
EXPOSE 81

ENTRYPOINT [ "supervisord" ]
