[ -z $DOCKER_HOST ] || IP=$(echo $DOCKER_HOST | sed 's;.*//\(.*\):.*;\1;')
IP=${IP:-$(ifconfig | awk '/inet .*10/{gsub(/.*:/,"",$2);print $2;exit}')}

echo "Clean up previous example"
curl -X DELETE -H "Content-Type: application/json" http://${IP}:8080/v2/apps/simplewebapp?force=true >/dev/null 2>&1
sleep 1
echo "Start a new one"
curl -X POST -H "Content-Type: application/json" http://${IP}:8080/v2/apps/ -d@deploy_marathon.json
