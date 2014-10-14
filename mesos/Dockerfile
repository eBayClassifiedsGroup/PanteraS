FROM ubuntu:14.04
MAINTAINER Mark O'Connor <mark@myspotontheweb.com>

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
RUN apt-get -y update
RUN apt-get -y install \
	supervisor \
	mesos \
	marathon \
	chronos \
	curl \
	python-pip

RUN pip install supervisor-stdout

RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8
