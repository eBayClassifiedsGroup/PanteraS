FROM mesos
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

RUN echo 'docker,mesos' > /etc/mesos-slave/containerizers
RUN echo '5mins' > /etc/mesos-slave/executor_registration_timeout
RUN echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9
RUN apt-get update && apt-get install -y lxc-docker

CMD ["--master=zk://zookeeper:2181/mesos", "--containerizers=docker,mesos"]

ENTRYPOINT ["mesos-slave"]
