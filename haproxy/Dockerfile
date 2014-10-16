FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul_haproxy
RUN mkdir -p /opt/haproxy/mount

ENV HOME /opt/consul_haproxy
ENV GOPATH /.go
WORKDIR /opt/consul_haproxy

# Install consul-haproxy
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install golang git \
    && go get -u github.com/hashicorp/consul-haproxy \
    && cp /.go/bin/consul-haproxy .

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor python-pip

# Install HAproxy
RUN sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y haproxy=1.5.3-1~ubuntu14.04.1 \
    && sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
    && rm -rf /var/lib/apt/lists/*


RUN pip install supervisor-stdout

# Add files.
ADD haproxy.cfg /etc/haproxy/haproxy.cfg
ADD haproxy.sh /opt/haproxy/haproxy.sh
ADD in.conf /opt/consul_haproxy/in.conf
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Define mountable directories.
VOLUME ["/haproxy-override"]

ENTRYPOINT [ "supervisord" ]
#ENTRYPOINT [ "./consul-haproxy", "-in", "in.conf", "-out", "/etc/haproxy/haproxy.cfg" ]

# Expose ports.
EXPOSE 80
EXPOSE 81
