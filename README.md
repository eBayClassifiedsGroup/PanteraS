# PanteraS - Platform as a Service in a box
"One container to rule them all"

## Goal
The goal is to spawn a complete dockerized environment,  
containing all necessary components for a PaaS,  
fully transferable between any kind of development stage: laptop / integration / production,  
highly robust, highly available, fail tolerance,  
where deployment part is fully independent from a running part.  
Services supposed to be spawn in a second, fully scalable, easy to monitor, debug and orchestrate.

## Architecture

### Components
- Mesos + Marathon + ZooKeeper (orchestration components)
- Consul (K/V store, monitoring, service directory and registry)  + Registrator (automating register/ deregister)
- HAproxy + consul-template (load balancer with dynamic config generation)

![PanteraS Architecture](https://s3.amazonaws.com/easel.ly/all_easels/19186/panteras/image.jpg)


##### Master mode Container
![Consul multi DC](https://s3.amazonaws.com/easel.ly/all_easels/19186/MasterMode/image.jpg)

##### Slave mode Container
![Slave mode](https://s3.amazonaws.com/easel.ly/all_easels/19186/SlaveMode/image.jpg)

##### Multiple Datacenter supporeted by Consul
![Master mode](http://www.easel.ly/viewEasel/1702056)





## Usage:

##### Stand alone mode (master and slave in one box)
    # vagrant up

or  

    # ./generate_yml.sh
    # docker-compose up -d

#### 3 Masters + N salves:

##### Configure zookeeper and consul:

    everyhost# cd panteras
    everyhost# mkdir restricted
    everyhost# echo 'ZOOKEEPER_HOSTS="masterhost-1:2181,masterhost-2:2181,masterhost-3:2181"' >> restricted/host
    everyhost# echo 'CONSUL_HOSTS="-join=masterhost-1 -join=masterhost-2 -join=masterhost-3"' >> restricted/host
    
    masterhost-1# echo "ZOOKEEPER_ID=1" >> restricted/host
    masterhost-2# echo "ZOOKEEPER_ID=2" >> restricted/host
    masterhost-3# echo "ZOOKEEPER_ID=3" >> restricted/host
    
##### Start containers:

    masterhost-n# ./generate_yml.sh
    masterhost-n# docker-compose up -d

    slavehost-n# MASTER=false ./generate_yml.sh
    slavehost-n# docker-compose up -d

### Web Interfaces

You can reach the PaaS components
on the following ports:

- HAproxy: http://hostname:81
- Consul: http://hostname:8500
- Marathon: http://hostname:8080
- Mesos: http://hostname:5050
- Supervisord: http://hostname:9000

### Services Accessibility

You might want to access the PaaS and services
with your browser directly via service name like:

http://your_service.service.consul

This could be problematic. It depends where you run docker host.
We have prepared two services that might help you solving this problem.

DNS - which supposed to be running on every docker host,
it is important that you have only one DNS server occupying port 53 on docker host,
you might need to disable yours, if you have already configured.

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

### Running an example application inside PaaS

      $ cd examples/SimpleWebappPython
      $ ./build-docker-image.sh
      $ ./start_with_marathon.sh

which gonna spawn 4 containers described in deploy1_marathon.json and deploy2_marathon.json
2 services with 2 instances each, that can be accessed for humans via browser:

http://python1.service.consul  
http://python2.service.consul

HAproxy gonna ballance services between ports,  
which has been mapped and assigned by marathon.

For non human access, like services intercommunication, you can use direct access 
using DNS consul SRV abilities, to verify answers:

      $ dig python1.service.consul +tcp SRV

or asking consul DNS directly:

      $ dig @$CONSUL_IP -p8600  python1.service.consul +tcp SRV

remmeber to disable DNS caching in your future services.

## References

[1] https://www.docker.com/  
[2] http://www.fig.sh/  
[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment

