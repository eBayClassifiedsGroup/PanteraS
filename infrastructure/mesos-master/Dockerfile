FROM mesos
MAINTAINER Mark O'Connor <mark@myspotontheweb.com>

EXPOSE 5050
EXPOSE 8080

RUN rm /etc/mesos/zk
ADD supervisord.conf /etc/supervisor/supervisord.conf

ENTRYPOINT ["supervisord"]
