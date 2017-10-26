paas-connect ()
{
    if [ -z "$1" ]; then
        echo "For connecting to service provide service_name/regex/substring as first parameter.";
        paas_image=$(sudo docker ps | awk '/panteras/{print $NF}')
        [ $paas_image ] && {
            echo "Connecting to PaaS image instead..."
            sudo docker exec -ti $paas_image bash
        }
    else
        for i in $(paas-list | awk 'NR>1 {print $1":"$2}');
        do
            name=${i##*:}
            id=${i%%:*}
            if [[ $name =~ $1 ]]; then
                echo "Connecting to ${id}...";
                sudo docker exec -ti $id bash;
            fi;
        done;
    fi
}

paas-list ()
{
    all_containers="$(sudo docker inspect $(sudo docker ps -q))";
    count=$(echo "$all_containers"|jshon -l);
    count=$(($count-1));
    max_len_app_id=$(echo "$all_containers"|jshon -a -e Config -e Env -a -u | awk -F\= '/MARATHON_APP_ID/{print $2}'| wc -L)
    printf "%12s %-${max_len_app_id}s %-13s %6s %6s %-9s\n" "DOCKER-ID" "MARATHON_APP_ID" "HOST" "PORT" "MEM" "XMX";
    for i in $(seq 0 $count);
    do
        unset MARATHON_APP_ID JAVA_XMX;
        values=$(echo "$all_containers"|jshon -e $i -e Config -e Env -a -u);
        id=$(echo "$all_containers"|jshon -e $i -e Id -u);
        eval "${values}" > /dev/null 2>&1;
        [ $MARATHON_APP_ID ] && printf "%-12s %-${max_len_app_id}s %-13s %6s %5sm %-9s\n" ${id:0:12} $MARATHON_APP_ID ${HOST%%.*} $PORT ${MARATHON_APP_RESOURCE_MEM%%.*} $JAVA_XMX;
    done | sort -k2,2
} 2>/dev/null

echo
paas-list
echo
echo "Useful commands:"
echo " paas-list                           | to get the list of running marathon app"
echo " paas-connect <marathon_app_id>      | to get the container's shell(s)"
echo " supervisorctl status                | to get status of all PaaS services"
echo " mesos_consul_consistency_check [-d] | to check consistency"
echo " marathon_deploy                     | to deploy yaml plan from command line"

# If inside container
[ -f /.dockerenv ] && export PS1="\[\e[01;32m\]\u@\h\[\e[m\][\[\e[31m\]PanteraS\[\e[m\]]:\[\e[01;34m\]\w\[\e[m\]\$ "
