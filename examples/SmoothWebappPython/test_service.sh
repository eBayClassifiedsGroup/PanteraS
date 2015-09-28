./build-docker-image.sh

json2yaml deploy0_marathon.json > deploy.yml
marathon_deploy -e PRODUCTION -u http://$IP:8080

sleep 20
docker images
docker ps
for i in {1..20}; do 
  curl --fail -H 'Host: python-smooth.service.consul' http://${IP}/cgi-bin/index
done
