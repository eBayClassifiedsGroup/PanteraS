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

![PanteraS Architecture](http://s3.amazonaws.com/easel.ly/all_easels/19186/panteras/image.jpg)


##### Master+SLave mode Container
This is the default configuration, that starts all components inside container.  
It is recommended to run 3 or 5 master containers to ensure high availability of the PasteraS cluster.

![Master Mode](http://s3.amazonaws.com/easel.ly/all_easels/19186/MasterMode/image.jpg)

##### Only Slave mode Container
Slave mode is enabled by `MASTER=false`  
In this mode starts only slave components, (master part is excluded)  
You can run as many slaves as you wish - this is fully scalable.

![Slave Mode](http://s3.amazonaws.com/easel.ly/all_easels/19186/SlaveMode/image.jpg)

##### Multiple Datacenter supporeted by Consul
To connect multiple datacenter use `consul join -wan <server 1> <server 2>`

![Consul multi DC](https://s3.amazonaws.com/easel.ly/all_easels/19186/consul/image.jpg)

##### Combination of deamons startup

Depending on `MASTER` and `SLAVE` you can define role of the container

   daemon\role  | default   | Only Master | Only Slave   |
    -----------:|:----------------:|:-----------:|:-------------:|
                |`MASTER=true`     |`MASTER=true`| `MASTER=false`|
                |`SLAVE=true`      |`SLAVE=false`| `SLAVE=true`  |
          Consul| x | x | x |
    Mesos Master| x | x | - |
    Marathon    | x | x | - |
    Zookeeper   | x | x | - |
 Consul-template| x | - | x |
    Haproxy     | x | - | x |
    Mesos Slave | x | - | x |
     Registrator| x | - | x |
         dnsmasq| x | x | x |
        

## Usage:
Clone it
```
git clone https://github.com/eBayClassifiedsGroup/PanteraS.git
cd PanteraS
```
##### Default: Stand alone mode
(master and slave in one box)
```
# vagrant up
```
or
```
# IP=<DOCKER_HOST_IP> ./generate_yml.sh
# docker-compose up -d
```


#### 3 Masters + N slaves:

Configure zookeeper and consul:
```
everyhost# mkdir restricted
everyhost# echo 'ZOOKEEPER_HOSTS="masterhost-1:2181,masterhost-2:2181,masterhost-3:2181"' >> restricted/host
everyhost# echo 'CONSUL_HOSTS="-join=masterhost-1 -join=masterhost-2 -join=masterhost-3"' >> restricted/host
everyhost# echo 'MESOS_MASTER_QUORUM=2' >> restricted/host
```
Lets set only masterhost-1 to bootstrap the consul
``` 
masterhost-1# echo 'CONSUL_PARAMS="-bootstrap-expect 3"' >> restricted/host
masterhost-1# echo 'ZOOKEEPER_ID=1' >> restricted/host
masterhost-2# echo 'ZOOKEEPER_ID=2' >> restricted/host
masterhost-3# echo 'ZOOKEEPER_ID=3' >> restricted/host
```    
Optionally, if you have multiple IPs,  
set an IP address of docker host (do not use docker0 interface IP)  
if you don't set - it will try to guess `dig +short ${HOSTNAME}`
``` 
masterhost-1# echo 'IP=x.x.x.1' >> restricted/host
masterhost-2# echo 'IP=x.x.x.2' >> restricted/host
masterhost-3# echo 'IP=x.x.x.3' >> restricted/host
```    

##### Start containers:
```
masterhost-n# ./generate_yml.sh
masterhost-n# docker-compose up -d
```
```
slavehost-n# MASTER=false ./generate_yml.sh
slavehost-n# docker-compose up -d
```

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
an example server we have created for you (in optional),
but you need to provide certificates and config file,
it might be little bit complex for the beginers,
so you might to try second option first.

B. SSHuttle - use https://github.com/apenwarr/sshuttle project so you can tunnel DNS traffic over ssh
but you have to have ssh daemon running in some container.

### Running an example application inside PaaS

```
$ cd examples/SimpleWebappPython
$ ./build-docker-image.sh
$ ./start_with_marathon.sh
```

which gonna spawn 4 containers described in `deploy1_marathon.json` and `deploy2_marathon.json`
2 services with 2 instances each, that can be accessed for humans via browser:

http://python1.service.consul  
http://python2.service.consul

HAproxy gonna ballance services between ports,  
which has been mapped and assigned by marathon.

For non human access, like services intercommunication, you can use direct access 
using DNS consul SRV abilities, to verify answers:

```
$ dig python1.service.consul +tcp SRV
```

or asking consul DNS directly:

```
$ dig @$CONSUL_IP -p8600  python1.service.consul +tcp SRV
```

remmeber to disable DNS caching in your future services.

## References

[1] https://www.docker.com/  
[2] http://docs.docker.com/compose/  
[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment  
[4] http://www.consul.io/docs/  

