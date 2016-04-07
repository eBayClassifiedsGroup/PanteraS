[![Build Status](https://travis-ci.org/eBayClassifiedsGroup/PanteraS.svg?branch=master)](https://travis-ci.org/eBayClassifiedsGroup/PanteraS)
[![Docker Hub](https://img.shields.io/badge/docker-ready-blue.svg)](https://hub.docker.com/r/panteras/paas-in-a-box/)
[![Current Release](http://img.shields.io/badge/release-0.2.1-blue.svg)](https://github.com/eBayClassifiedsGroup/PanteraS/releases/tag/v0.2.1)

# PanteraS <br> _entire_ Platform as a Service, in a box
_"One container to rule them all"_

Now you can create a completely dockerized environment for a platform as a service (PaaS) in no time!  
PanteraS contains all the necessary components for a highly robust, highly available, fault tolerant PaaS.  
The goal is to spawn fully scalable, easy to monitor, debug and orchestrate services in seconds. Totally independent of
the underlying infrastructure. PanteraS is also fully transferable between development stages. You can run it on your laptop, 
test and production systems without hassle.

_"You shall ~~not~~ PaaS"_

## Architecture

### Components
- Mesos + Marathon + ZooKeeper + Chronos (orchestration components)
- Consul (K/V store, monitoring, service directory and registry)  + Registrator (automating register/ deregister)
- HAproxy + consul-template (load balancer with dynamic config generation)

![PanteraS Architecture](http://s3.amazonaws.com/easel.ly/all_easels/19186/panteras/image.jpg#)


##### Master+Slave mode Container
This is the default configuration. It will start all components inside a container.  
It is recommended to run 3 or 5 master containers to ensure high availability of the PasteraS cluster.

![Master Mode](http://s3.amazonaws.com/easel.ly/all_easels/19186/MasterMode/image.jpg#)

##### Only Slave mode Container
Slave mode is enabled by `MASTER=false`  
In this mode only slave components will start (master part is excluded).
You can run as many slaves as you wish - this is fully scalable.

![Slave Mode](http://s3.amazonaws.com/easel.ly/all_easels/19186/SlaveMode/image.jpg)

##### Multiple Datacenter supported by Consul
To connect multiple datacenters use `consul join -wan <server 1> <server 2>`

![Consul multi DC](https://s3.amazonaws.com/easel.ly/all_easels/19186/consul/image.jpg)

##### Combination of daemons startup

Depending on `MASTER` and `SLAVE` you can define role of the container

   daemon\role  | default   | Only Master | Only Slave   |
    -----------:|:----------------:|:-----------:|:-------------:|
                |`MASTER=true`     |`MASTER=true`| `MASTER=false`|
                |`SLAVE=true`      |`SLAVE=false`| `SLAVE=true`  |
          Consul| x | x | x |
    Mesos Master| x | x | - |
    Marathon    | x | x | - |
    Zookeeper   | x | x | - |
    Chronos     | x | x | - |
 Consul-template| x | - | x |
    Haproxy     | x | - | x |
    Mesos Slave | x | - | x |
     Registrator| x | - | x |
         dnsmasq| x | x | x |
        

## Requirements:
- docker >= 1.9.1
- docker-compose >= 1.5.1

## Usage:
Clone it
```
git clone https://github.com/eBayClassifiedsGroup/PanteraS.git
cd PanteraS
```
#### Default: Stand alone mode
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
if you don't set it - it will try to guess `dig +short ${HOSTNAME}`
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

## Web Interfaces

You can reach the PaaS components
on the following ports:

- HAproxy: http://hostname:81
- Consul: http://hostname:8500
- Chronos: http://hostname:4400
- Marathon: http://hostname:8080
- Mesos: http://hostname:5050
- Supervisord: http://hostname:9000

## Listening address

All PaaS components listen default on all interfaces (to all addresses: `0.0.0.0`),  
which might be dangerous if you want to expose the PaaS.  
Use ENV `LISTEN_IP` if you want to listen on specific IP address.  
for example:  
`echo LISTEN_IP=192.168.10.10 >> restricted/host`  
This might not work for all services like Marathon or Chronos that has some additional random ports.

## Services Accessibility

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
it might be little bit complex for the beginners,
so you might to try second option first.

B. SSHuttle - use https://github.com/apenwarr/sshuttle project so you can tunnel DNS traffic over ssh
but you have to have ssh daemon running in some container.

## Running an example application

There are two examples available:  
`SimpleWebappPython` - basic example - spawn 2x2 containers  
`SmoothWebappPython` - similar to previous one, but with smooth scaling down  

HAproxy will balance the ports which where mapped and assigned by marathon. 

For non human access like services intercommunication, you can use direct access 
using DNS consul SRV abilities, to verify answers:

```
$ dig python.service.consul +tcp SRV
```

or ask consul DNS directly:

```
$ dig @$CONSUL_IP -p8600  python.service.consul +tcp SRV
```

Remember to disable DNS caching in your future services.

## Put service into HAproxy HTTP load-balancer

In order to put a service `my_service` into the `HTTP` load-balancer (`HAproxy`), you need to add a `consul` tag `haproxy` 
(ENV `SERVICE_TAGS="haproxy"`) to the JSON deployment plan for `my_service` (see examples). `my_service` is then accessible
on port `80` via `my_service.service.consul:80` and/or `my_service.service.<my_dc>.consul:80`.

If you provide an additional environment variable `HAPROXY_ADD_DOMAIN` during the configuration phase you can access the
service with that domain appended to the service name as well, e.g., with `HAPROXY_ADD_DOMAIN=".my.own.domain.com"` you
can access the service `my_service` via `my_service.my.own.domain.com:80` (if the IP address returned by a DNS query for
`*.my.own.domain.com` is pointing to one of the nodes running an `HAProxy` instance).

You can also provide the additional `consul` tag `haproxy_route` with a corresponding value in order to dispatch the
service based on the beginning of the `URL`; e.g., if you add the additional tag `haproxy_route=/minions` to the service
definition for service `gru`, all `HTTP` requests against any of the cluster nodes on port `80` starting with `/minions/`
will be re-routed to and load-balanced for the service `gru` (e.g., `http://cluster_node.my_company.com/minions/say/banana`).
Note that no `URL` rewrite happens, so the service gets the full `URL` (`/minions/say/banana`) passed in.

## Put service into HAproxy TCP load-balancer

In order to put a service `my_service` into the `TCP` load-balancer (`HAproxy`), you need to add a `consul` tag `haproxy_tcp` specifying
the specific `<port>` (ENV `SERVICE_TAGS="haproxy_tcp=<port>"`) to the JSON deployment plan for `my_service`. It is also recommended
to set the same `<port>` as the `servicePort` in the `docker` part of the JSON deployment plan. `my_service` is then accessible on
the specific `<port>` on all cluster nodes, e.g., `my_service.service.consul:<port>` and/or `my_service.service.<my_dc>.consul:<port>`.

## Create A/B test services (AKA canaries services)

1. You need to create services with the same consul name (ENV `SERVICE_NAME="consul_service"`), but different marathon `id` in every JSON deployment plan (see examples)
2. You need to set different [weights](http://cbonte.github.io/haproxy-dconv/configuration-1.5.html#weight) for those services. You can propagate weight value using consul tag  
(ENV `SERVICE_TAGS="haproxy,weight=1"`)
3. We set the default weight value for `100` (max is `256`).

## Deploy using marathon_deploy

You can deploy your services using `marathon_deploy`, which also understand YAML and JSON files.
As a benefit, you can have static part in YAML deployment plans, and dynamic part (like version or URL)
set with `ENV` variables, specified with `%%MACROS%%` in deployment plan.

```apt-get install ruby1.9.1-dev```  
```gem install marathon_deploy```  

more info: https://github.com/eBayClassifiedsGroup/marathon_deploy


## References

[1] https://www.docker.com/  
[2] http://docs.docker.com/compose/  
[3] http://stackoverflow.com/questions/25217208/setting-up-a-docker-fig-mesos-environment  
[4] http://www.consul.io/docs/  

