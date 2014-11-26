# Platform as a Service in a box

This project has the goal to spawn a complete environment
containing all necessary components for a PaaS environment:

- Mesos + Marathon + ZooKeeper (orchestration components)
- Consul (K/V store, monitoring, service directory and registry)
- HAproxy + consul-haproxy (load balancer with automatic config generation)

## Usage

### tl;dr
Execute:
	$ install.sh

- If you're on a Mac OSX box, this will install the [Vagrant](#vagrant) Paas in a Box below.<br />
- If you are on an Ubuntu box, this will install the [Standalone](#standalone) Paas in a Box below.<br />
Then manually run the command that is indicated by the script to ssh into the target VM.

### Vagrant

The easiest way to start is using vagrant.
Please make sure you have the following packages installed:

- vagrant >1.5
- VirtualBox

Then execute:

	$ vagrant up

This will start an Ubuntu VM,
install all prerequisites and spawn all components.
At the end of the process, you can run 

	$ vagrant ssh

to ssh into the VM and get access to all the docker instances.

### Standalone

If you prefer to run the PaaS components directly
on your linux box or in an environment like boot2docker
you can do so by installing the following packages:

- docker
- fig.sh

Execute the following command _once_
in order to build the necessary docker images:

	$ sudo ./build-docker-images.sh

Then you have to create a valid fig.yml file:

	$ HOSTNAME=boot2docker IP=192.168.59.103 ./genfig.sh

Where HOSTNAME and IP correspond to your local VM (i.e. boot2docker)

To start an instance of each service execute:

	$ fig up -d

### Web Interfaces

Given the `IP`/`hostname` above
you can reach the PaaS components
on the following ports:

- Consul: http://hostname:8500
- Marathon: http://hostname:8080
- Mesos: http://hostname:5050

## References

[1] https://www.docker.com/

[2] http://www.fig.sh/

[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment
