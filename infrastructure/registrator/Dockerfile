FROM paas
MAINTAINER Jonathan Colby "jcolby@team.mobile.de"

RUN mkdir /opt/registrator
ENV PATH $PATH:/opt/registrator
ENV GOPATH /opt/registrator/go

WORKDIR /opt/registrator

RUN . /opt/versions.conf \
    && apt-get -y install golang git \
    && go get -u -tags ${REGISTRATOR_VERSION} github.com/gliderlabs/registrator \
    && cp $GOPATH/bin/registrator .

# Builds are not supported any more
#  && wget https://github.com/progrium/registrator/releases/download/v${REGISTRATOR_VERSION}/registrator_${REGISTRATOR_VERSION}_linux_x86_64.tgz \
#  && tar zxf registrator_${REGISTRATOR_VERSION}_linux_x86_64.tgz

ENV HOME /opt/registrator

ENV DOCKER_HOST unix:///tmp/docker.sock

ADD supervisord.conf /etc/supervisor/supervisord.conf

ENTRYPOINT ["supervisord"]
