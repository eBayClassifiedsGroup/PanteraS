FROM mesos
MAINTAINER Wojciech Sielski "wsielski@team.mobile.de"

# /etc/mesos-slave settings are /usr/bin/mesos-init-wrapper specific
#RUN echo 'docker,mesos' > /etc/mesos-slave/containerizers
#RUN echo '5mins' > /etc/mesos-slave/executor_registration_timeout

RUN echo 'deb http://get.docker.io/ubuntu docker main' > /etc/apt/sources.list.d/docker.list
#RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv D8576A8BA88D21E9 && gpg --export --armor D8576A8BA88D21E9 | apt-key add -
RUN . /opt/versions.conf \
    && apt-get update \
    && apt-get install -y lxc-docker-${DOCKER_VERSION}

#CMD ["--master=zk://zookeeper:2181/mesos", "--containerizers=docker,mesos", "--executor_registration_timeout=5mins"]
#ENTRYPOINT ["mesos-slave"]

ADD supervisord.conf /etc/supervisor/supervisord.conf

# Adding docker wrapper, so CONTAINER_NAME will be available for every mesos containers
ADD docker /usr/local/sbin/docker

ENTRYPOINT ["supervisord"]

