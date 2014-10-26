zk:
  image: mesos
  command: /usr/share/zookeeper/bin/zkServer.sh start-foreground
  name: zk

master:
  image: mesos-master
  ports:
    - "5050:5050"
    - "8080:8080"
    - "9001:9001"
  links:
    - "zk:zookeeper"
  hostname: $HOSTNAME
  name: mesos-master

slave:
  privileged: true
  image: mesos-slave
  links:
    - "zk:zookeeper"
  volumes:
    - "/var/run/docker.sock:/var/run/docker.sock"
    - "/var/lib/docker:/var/lib/docker"
    - "/usr/local/bin/docker:/usr/local/bin/docker"
    - "/sys:/sys"
    - "/tmp/mesos:/tmp/mesos"
  ports:
    - "5051:5051"
    - "9002:9001"
  hostname: $HOSTNAME
  name: mesos-slave

consul:
  environment:
    MASTER_IP: $IP
    MASTER_HOST: $HOSTNAME
    DC: $DC
    CONSUL_BOOTSTRAP: \"$BOOTSTRAP\"
    CONSUL_MODE: \"$MODE\"
  image: consul
  ports:
    - "8300:8300"
    - "8301:8301"
    - "8301:8301/udp"
    - "8302:8302"
    - "8302:8302/udp"
    - "8400:8400"
    - "8500:8500"
    - "8600:8600"
    - "8600:8600/udp"
    - "9003:9001"
  hostname: $HOSTNAME
  name: consul

haproxy:
  environment:
    MASTER_IP: $IP
    DC: $DC
  image: haproxy
  ports:
    - "80:80"
    - "81:81"
    - "9004:9001"
  hostname: $HOSTNAME
  name: haproxy

openvpn:
  privileged: true
  image: openvpn
  volumes:
    - "/etc/openvpn:/etc/openvpn"
    - "/etc/nslcd.conf:/etc/nslcd.conf"
    - "/etc/ssl/certs/:/etc/ssl/certs/"
    - "/etc/nsswitch.conf:/etc/nsswitch.conf"
  ports:
    - "1194:1194"
    - "1194:1194/udp"
  hostname: $HOSTNAME
  name: openvpn
  net: host

