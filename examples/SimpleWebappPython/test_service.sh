json2yaml deploy0_marathon.json > deploy.yml

#marathon_deploy -e PRODUCTION -u http://$IP:8080
./start_with_marathon.sh deploy0_marathon.json

sleep 20
docker images
docker ps
for i in {1..20}; do 
  curl --fail -H 'Host: python.service.consul' http://${IP}
done

docker exec -ti panteras_panteras_1 supervisorctl status
curl -s http://${IP}:8080/v2/leader
curl -s http://${IP}:8080/v2/info
curl -I -s http://${IP}:5050/master/health
curl -s http://${IP}:5050/system/stats.json
