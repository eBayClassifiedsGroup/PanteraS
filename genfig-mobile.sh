#!/bin/sh

[ -z $IP ] && IP=$(ifconfig | awk '/inet addr:10/{gsub(/.*:/,"",$2);print $2;exit}')

DC=$(ifconfig | awk -F\. '/inet addr:10/{print $2;exit}')
INTEGRA=$(ifconfig | awk -F\. '/inet addr:10/{print $3;exit}')

FULL_DC='UNKNOWN'
case $DC in
  44) FULL_DC="44_Integra_${INTEGRA}";;
  38) FULL_DC="38_Berlin";;
  46) FULL_DC="46_Frankfurt";;
  47) FULL_DC="47_Amsterdam";;
esac

BOOTSTRAP=""
HOST_NR=$(echo ${HOSTNAME} | awk -F- '{print $NF}')
HOST=$(echo ${HOSTNAME} | awk -F- '{print $(NF-1)}')
[ ${HOST_NR} = "1" ] && {
  BOOTSTRAP="-bootstrap-expect 1"
} || {
  BOOTSTRAP=$(for i in $(seq 1 $((${HOST_NR}-1)) ); do echo -n "-join=$HOST-$i "; done)
}

[ ${FULL_DC} = 'UNKNOWN' ] && BOOTSTRAP="-bootstrap-expect 1"

CONSUL_NAME="${HOSTNAME}.consul"

CONSUL_CMD="${BOOTSTRAP} -advertise ${IP} -server -node=${HOSTNAME} -dc=${FULL_DC}"

eval "`cat fig.yml.tpl| sed  's/^\(.*\)$/echo "\1"/'`" >fig.yml
