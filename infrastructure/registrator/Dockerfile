FROM paas
MAINTAINER Jonathan Colby "jcolby@team.mobile.de"

RUN mkdir /opt/registrator
ENV HOME /opt/registrator

ENV PATH $PATH:/opt/registrator
WORKDIR /opt/registrator


RUN . /opt/versions.conf \
  && wget https://github.com/progrium/registrator/releases/download/v${REGISTRATOR_VERSION}/registrator_${REGISTRATOR_VERSION}_linux_x86_64.tgz \
  && tar zxf registrator_${REGISTRATOR_VERSION}_linux_x86_64.tgz

ENV DOCKER_HOST unix:///tmp/docker.sock
ENTRYPOINT ["/opt/registrator/registrator"]
