FROM mesos
MAINTAINER Mark O'Connor <mark@myspotontheweb.com>

EXPOSE 5050
EXPOSE 8080

RUN echo "zk://zookeeper:2181/mesos" > /etc/mesos/zk
ADD supervisord.conf /etc/supervisor/supervisord.conf

ENTRYPOINT ["supervisord"]