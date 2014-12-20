FROM paas

MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN mkdir /opt/consul_template
RUN mkdir -p /opt/haproxy/mount

ENV HOME /opt/consul_template
WORKDIR /opt/consul_template

RUN . /opt/versions.conf \
    && sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
    haproxy="${HAPROXY_VERSION}"

# HAproxy
RUN sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/haproxy \
    && rm -rf /var/lib/apt/lists/*

# consul-haproxy
RUN . /opt/versions.conf \
    && wget https://github.com/hashicorp/consul-template/releases/download/v${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz \
    && tar zxf consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tar.gz \
    && ln -s consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64/consul-template .

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
