# Platform as a Service in the box

## Prerequisites

- Docker
- ZK + Mesos + Marathon = as an orchestration tool
- Consul = as K/V, monitoring, Service Directory and Registry
- HAproxy + consul-haproxy = as LoadBalancer with automatic config generation
- Fig.sh = as a spawner for developers and intgeration envirnment

## Usage

In order to build the docker image
you have to execute the following command _once_:

	$ ./build.sh

Then you have to create a valid fig.yml file:

	$ HOSTNAME=boot2docker IP=192.168.59.103 ./genfig.sh

Where HOSTNAME and IP correspond to your local VM (i.e. boot2docker)

To start an instance of each service execute:

	$ fig up -d

## References

[1] https://www.docker.com/

[2] http://www.fig.sh/

[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment
