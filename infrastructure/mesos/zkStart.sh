#!/bin/bash

# Prepare multiserver config
ZK_CFG="/etc/zookeeper/conf/zoo.cfg"
ZK_ID_CFG="/etc/zookeeper/conf/myid"

[ -z ${ZK_ID} ] || { 
  echo ${ZK_ID} > ${ZK_ID_CFG} && \
  {
    [ -z ${ZK_SERVER_1} ] || echo ${ZK_SERVER_1} >> ${ZK_CFG}
    [ -z ${ZK_SERVER_2} ] || echo ${ZK_SERVER_2} >> ${ZK_CFG}
    [ -z ${ZK_SERVER_3} ] || echo ${ZK_SERVER_3} >> ${ZK_CFG}
  }
}

/usr/share/zookeeper/bin/zkServer.sh start-foreground
