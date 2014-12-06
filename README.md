# Platform as a Service in a box

## Goal
The goal is to spawn a complete dockerized environment,
containing all necessary components for a PaaS,
fully transferable between any kind of development stage: laptop / integration / production 
highly robust, highly available, fail tolerance,
where deployment part is fully independent from a running part.
Services supposed to be spawn in a second, fully scalable, easy to monitor, debug and orchestrate.

## Components
- Mesos + Marathon + ZooKeeper (orchestration components)
- Consul (K/V store, monitoring, service directory and registry)
- HAproxy + consul-template (load balancer with automatic config generation)

## Install

There are few ways you can run the project:
1. vagrant
2. boot2docker
3. standalone on linux

### Installing using Vagrant

Execute:
	$ ./install.sh -m vagrant

- If you're on a Mac OSX box, this will install the [Vagrant](#vagrant) Paas in a Box below.<br />
- If you are on an Ubuntu box, this will install the [Standalone](#standalone) Paas in a Box below.<br />
Then manually run the command that is indicated by the script to ssh into the target VM.

The easiest way to start is using vagrant.
Please make sure you have the following packages installed:

- vagrant >1.5
- VirtualBox

or start manuallly:

	$ vagrant up

This will start an Ubuntu VM,
install all prerequisites and spawn all components.
At the end of the process, you can run 

	$ vagrant ssh

to ssh into the VM and get access to all the docker instances.

### Installing using boot2docker

be sure you have virtualbox, boot2docker and fig installed.
(VirtualBox you have to install manually) then just run 

         $ ./install.sh -m boot2docker

or you can start manually:

         $ brew install boot2docker
         $ brew install fig
         $ boot2docker up
         $ $(boot2docker init)

### Standalone

If you prefer to run the PaaS components directly
on your linux box you can do so by installing the following packages:

- docker
- fig

## Configuration

you might need to modify / reconfigure the project.
Here are some configuration info:

Execute the following command _once_
in order to build the necessary docker images:

	$ ./build-docker-images.sh

Then you have to create a valid fig.yml file:

        $ ./genfig.sh
       
or if you want to modify docker HOSTNAME and IP overwrite variables like:
Where HOSTNAME and IP correspond to your local VM (i.e. boot2docker)

	$ HOSTNAME=boot2docker IP=192.168.59.103 ./genfig.sh

## Stopping and starting manually

You might need to start stop containers in a future:

To stop all

	$ fig stop

To start an instance of each service execute (first time):

	$ fig up -d 
To start containers which has been stopped:

	$ fig start

Use same commandis for stopping/starting specific container
just by adding its name like:

        $ fig stop haproxy

### Web Interfaces

Given the `IP`/`hostname` from above
you can reach the PaaS components
on the following ports:

- HAproxy: http://hostname:81 or http://hostname/haproxyStats
- Consul: http://hostname:8500
- Marathon: http://hostname:8080
- Mesos: http://hostname:5050

### Accessibility

You might want to access the PaaS and services
with your browser directly via service name like:

http://your_service.service.consul

This could be problematic. It depends where you run docker host.
We have prepared two services that might help you solving this problem.

DNS - which supposed to be running on every docker host,
it is important that you have only one DNS server occupying port 53 on docker host,
you might need to disable yours if you have already configured.

If you have direct access to the docker host DNS,
then just modify your /etc/resolv.conf adding its IP address.

If you do NOT have direct access to docker host DNS,
then you have two options:

A. use OpenVPN client
an example server we have created for you,
but you need to provide certificates and config file,
it might be little bit complex for the begining,
so you might to try second option first.

B. SSHuttle - use https://github.com/apenwarr/sshuttle project so you can tunnel DNS traffic over ssh
but you have to have ssh daemon running in some container.
Do NOT use for that:
- docker host itself
- containers that runs with "net: host"
- DNS container itself
rather use containers that have DNS in fig.yaml file configured.

### Running an example

$ cd examples/SimpleWebappPython
$ ./build-docker-image.sh
$ ./start_with_marathon.sh

which gonna spawn 4 containers described in deploy1_marathon.json and deploy2_marathon.json
2 services with 2 instances each, that can be accessed for humans via browser:

http://python1.service.consul
http://python2.service.consul

HAproxy gonna ballance services between ports
which has been mapped and assigned by marathon.

For non human access, like services intercommunication, you can use direct access 
using DNS consul SRV abilities, to verify answers:

dig python1.service.consul SRV

for debugging:
asking DNS directly:
dig @DOCKER_HOST -p53   python1.service.consul SRV

asking Consul directly:
dig @DOCKER_HOST -p8600 python1.service.consul SRV

remmeber to disable DNS caching in your future services.

## References

[1] https://www.docker.com/

[2] http://www.fig.sh/

[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment
