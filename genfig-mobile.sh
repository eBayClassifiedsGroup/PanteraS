#!/bin/sh

[ -z $IP ] && IP=$(ifconfig | awk '/inet addr:10/{gsub(/.*:/,"",$2);print $2;exit}')

DC_LOCAL=$(ifconfig | awk -F\. '/inet addr:10/{print $2;exit}')
INTEGRA=$(ifconfig | awk -F\. '/inet addr:10/{print $3;exit}')

DC='UNKNOWN'
case $DC_LOCAL in
  44) DC="44_Integra_${INTEGRA}";;
  38) DC="38_Berlin";;
  46) DC="46_Frankfurt";;
  47) DC="47_Amsterdam";;
esac

BOOTSTRAP=""
HOST_NR=$(echo ${HOSTNAME} | awk -F- '{print $NF}')
HOST=$(echo ${HOSTNAME} | awk -F- '{print $(NF-1)}')
[ ${HOST_NR} = "1" ] && {
  BOOTSTRAP="-bootstrap-expect 1"
} || {
  BOOTSTRAP=$(for i in $(seq 1 $((${HOST_NR}-1)) ); do echo -n "-join=$HOST-$i "; done)
}
[ ${DC} = 'UNKNOWN' ] && BOOTSTRAP="-bootstrap-expect 1"
MODE=" -server"

eval "`cat fig.yml.tpl| sed  's/^\(.*\)$/echo "\1"/'`" >fig.yml
