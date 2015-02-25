FROM mesos
MAINTAINER Mark O'Connor <mark@myspotontheweb.com>

EXPOSE 5050
EXPOSE 8080

RUN rm /etc/mesos/zk
ADD supervisord.conf /etc/supervisor/supervisord.conf

# Disable logger in start up script - we use supervisord so we need stdout/stderr
sed -i '72s/logged //' /usr/bin/marathon

ENTRYPOINT ["supervisord"]
