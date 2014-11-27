zk:
  image: ${REGISTRY}mesos
  command: /usr/share/zookeeper/bin/zkServer.sh start-foreground
  ports:
    - "2181:2181"
  hostname: $HOSTNAME-zk
  name: zk

master:
  environment:
    ZOOKEEPER_HOSTS: "$HOSTNAME:2181"
    MASTER_HOST: $HOSTNAME
  image: ${REGISTRY}mesos-master
  dns: $IP
  ports:
    - "5050:5050"
    - "8080:8080"
    - "9001:9001"
  hostname: $HOSTNAME-master
  name: mesos-master

slave:
  privileged: true
  environment:
    ZOOKEEPER_HOSTS: "$HOSTNAME:2181"
    MASTER_HOST: $HOSTNAME
  image: ${REGISTRY}mesos-slave
  command: "--master=zk://$IP:2181/mesos --containerizers=docker,mesos --executor_registration_timeout=5mins --hostname=$HOSTNAME"
  volumes:
    - "/var/run/docker.sock:/var/run/docker.sock"
    - "/var/lib/docker:/var/lib/docker"
    - "/usr/local/bin/docker:/usr/local/bin/docker"
    - "/sys:/sys"
    - "/tmp/mesos:/tmp/mesos"
  dns: $IP
  ports:
    - "5051:5051"
    - "9002:9001"
  hostname: $HOSTNAME-slave
  name: mesos-slave

consul:
  environment:
    MASTER_IP: $IP
    MASTER_HOST: $HOSTNAME
    DC: $DC
    CONSUL_BOOTSTRAP: \"$BOOTSTRAP\"
    CONSUL_MODE: \"$MODE\"
  image: ${REGISTRY}consul:latest
  ports:
    - "8300:8300"
    - "8301:8301"
    - "8301:8301/udp"
    - "8302:8302"
    - "8302:8302/udp"
    - "8400:8400"
    - "8500:8500"
    - "$IP:8600:8600"
    - "$IP:8600:8600/udp"
    - "9003:9001"
  hostname: $HOSTNAME-consul
  name: consul

haproxy:
  environment:
    MASTER_IP: $IP
    DC: $DC
  image: ${REGISTRY}haproxy
  ports:
    - "80:80"
    - "81:81"
    - "9004:9001"
  hostname: $HOSTNAME-haproxy
  name: haproxy

openvpn:
  privileged: true
  image: ${REGISTRY}openvpn
  volumes:
    ${VOL}
  ports:
    - "1194:1194"
    - "1194:1194/udp"
  hostname: $HOSTNAME-openvpn
  name: openvpn
  net: host

registrator:
  image: ${REGISTRY}registrator
  name: registrator
  hostname: $HOSTNAME-registrator
  volumes:
    - "/var/run/docker.sock:/tmp/docker.sock"
  command: consul://$IP:8500

dns:
  environment:
    MASTER_IP: $IP
    MASTER_HOSTNAME: $HOSTNAME
  ports:
    - "$IP:53:53"
    - "$IP:53:53/udp"
  volumes:
    - "/etc/resolv.conf:/etc/resolv.conf"
  privileged: true
  image: dnsmasq
  name: dnsmasq
  net: bridge
