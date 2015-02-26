dnsmasq:
  image: ${REGISTRY}dnsmasq
  environment:
    CONSUL_IP: ${CONSUL_IP}
    MASTER_HOST: ${HOSTNAME}
  ports:
    - "$IP:53:53"
    - "$IP:53:53/udp"
  volumes:
    ${DNS_VOL}
  privileged: true
  name: dnsmasq
  net: bridge

zk:
  environment:
    ZOOKEEPER_HOSTS: ${ZOOKEEPER_HOSTS}
    ${ZK_ID}
    ${ZK_ENV_SERVERS}
  image: ${REGISTRY}mesos
  command: /opt/zkStart.sh
  ports:
    - "2181:2181"
    - "2188:2188"
    - "2888:2888"
    - "3888:3888"
  hostname: ${HOSTNAME}-zk
  name: zk

master:
  image: ${REGISTRY}mesos-master
  environment:
    MASTER_HOST: ${HOSTNAME}
    ZOOKEEPER_HOSTS: ${ZOOKEEPER_HOSTS}
    MESOS_CLUSTER_NAME: ${MESOS_CLUSTER_NAME}
    CUSTOM_MESOS_MASTER_PARAMS: "${CUSTOM_MESOS_MASTER_PARAMS}"
    CUSTOM_MARATHON_PARAMS: "${CUSTOM_MARATHON_PARAMS}"
  volumes:
    - "/var/spool/marathon/artifacts/store:/var/spool/store"
  dns: $IP
  ports:
    - "5050:5050"
    - "8080:8080"
    - "9001:9001"
  hostname: ${HOSTNAME}-master
  name: mesos-master
  net: host

slave:
  image: ${REGISTRY}mesos-slave
  privileged: true
  environment:
    ZOOKEEPER_HOSTS: ${ZOOKEEPER_HOSTS}
    MASTER_HOST: ${HOSTNAME}
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
  hostname: ${HOSTNAME}-slave
  name: mesos-slave
  net: host

consul:
  image: ${REGISTRY}consul:latest
  environment:
    MASTER_IP: ${CONSUL_IP}
    MASTER_HOST: ${HOSTNAME}
    CONSUL_DC: ${CONSUL_DC}
    CONSUL_BOOTSTRAP: ${CONSUL_BOOTSTRAP}
    CONSUL_MODE: ${CONSUL_MODE}
  volumes:
    - "/var/run/docker.sock:/var/run/docker.sock"
  name: consul
  net: host

haproxy:
  image: ${REGISTRY}haproxy
  environment:
    CONSUL_IP: ${CONSUL_IP}
  ports:
    - "80:80"
    - "81:81"
    - "9004:9001"
  hostname: ${HOSTNAME}-haproxy
  name: haproxy

registrator:
  image: ${REGISTRY}registrator
  name: registrator
  hostname: ${HOSTNAME}-registrator
  volumes:
    - "/var/run/docker.sock:/tmp/docker.sock"
  command: consul://${CONSUL_IP}:8500

