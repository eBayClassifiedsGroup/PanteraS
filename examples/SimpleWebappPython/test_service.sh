json2yaml deploy0_marathon.json > deploy.yaml
marathon_deploy -e PRODUCTION

for i in {1..20}; do 
  curl --fail -H 'Host python.service.consul' $IP
done
