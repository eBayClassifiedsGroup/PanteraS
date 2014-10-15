zk:
  image: mesos
  command: /usr/share/zookeeper/bin/zkServer.sh start-foreground
master:
  image: mesos-master
  ports:
    - "5050:5050"
    - "8080:8080"
  links:
    - "zk:zookeeper"
  hostname: $HOSTNAME
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
  hostname: $HOSTNAME
consul:
  image: dockerregistry.mobile.rz:5000/library/consul:latest
  command: '\"$CONSUL_CMD\"'
  ports:
    - "$IP:8300:8300"
    - "$IP:8301:8301"
    - "$IP:8301:8301/udp"
    - "$IP:8302:8302"
    - "$IP:8302:8302/udp"
    - "$IP:8400:8400"
    - "$IP:8500:8500"
    - "$IP:8600:8600"
    - "$IP:8600:8600/udp"
    - "$IP:8053:53/udp"
  hostname: $HOSTNAME
  name: $NAME
