curl -X DELETE -H "Content-Type: application/json" http://localhost:8080/v2/apps/simplewebapp?force=true
sleep 1
curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps/ -d@deploy_marathon.json
