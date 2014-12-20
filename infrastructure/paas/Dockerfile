FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
    && apt-get install -y \
      python-pip \
      supervisor \
      wget \
      curl \
      unzip

RUN pip install supervisor-stdout

ADD versions.conf /opt/versions.conf
