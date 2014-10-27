echo "Clean up previous example"
curl -X DELETE -H "Content-Type: application/json" http://localhost:8080/v2/apps/simplewebapp?force=true >/dev/null 2>&1
sleep 1
echo "Start a new one"
curl -X POST -H "Content-Type: application/json" http://localhost:8080/v2/apps/ -d@deploy_marathon.json
