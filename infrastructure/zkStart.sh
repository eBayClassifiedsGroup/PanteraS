#!/bin/bash

# Prepare multiserver config
ZK_CFG="/etc/zookeeper/conf/zoo.cfg"
ZK_ID_CFG="/etc/zookeeper/conf/myid"

trap 'kill -TERM $ZK_PID' TERM INT

[  ${ZOOKEEPER_ID} ] &&  {
  [ ${ZOOKEEPER_ID} -gt 0 ] && {
    echo ${ZOOKEEPER_ID} > ${ZK_ID_CFG}
    id=0
    for server_port in $(echo ${ZOOKEEPER_HOSTS}|tr , \ );
    do
      id=$((${id}+1))
      server=${server_port%:*}
      grep -q "^server.${id}" ${ZK_CFG} \
        && sed -i "s/^server.${id}.*/server.${id}=${server}:2888:3888/" ${ZK_CFG} \
        || echo "server.${id}=${server}:2888:3888" >> ${ZK_CFG}
    done
  }
}

[ ${LISTEN_IP} ] && {
  grep -q "^clientPortAddress" ${ZK_CFG} \
    && sed -i "s/^clientPortAddress.*/clientPortAddress=${LISTEN_IP}/" ${ZK_CFG} \
    || echo "clientPortAddress=${LISTEN_IP}" >> ${ZK_CFG}
}

/usr/share/zookeeper/bin/zkServer.sh "$@" &
ZK_PID=$!
wait $ZK_PID
trap - TERM INT
wait $ZK_PID
exit $?
