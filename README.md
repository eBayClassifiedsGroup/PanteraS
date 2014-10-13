# Mesos @ Docker

## Prerequisites

- Docker
- Fig

## Usage

In order to build the docker image
you have to execute the following command _once_:

	$ ./build.sh

To start an instance of each service execute:

	$ fig up -d

Scale up with more slaves:

	$ fig scale slave=5

## References

[1] https://www.docker.com/

[2] http://www.fig.sh/

[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment