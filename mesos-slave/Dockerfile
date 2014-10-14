FROM mesos
MAINTAINER Mark O'Connor <mark@myspotontheweb.com>

RUN echo 'docker,mesos' > /etc/mesos-slave/containerizers
RUN echo '5mins' > /etc/mesos-slave/executor_registration_timeout

CMD ["--master=zk://zookeeper:2181/mesos", "–containerizers=docker,mesos"]

ENTRYPOINT ["mesos-slave"]