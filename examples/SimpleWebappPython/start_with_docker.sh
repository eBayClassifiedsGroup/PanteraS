PORT=8000
HOST=$(hostname -f)

echo "Clean up previous example"
docker kill $HOSTNAME-docker >/dev/null 2>&1
docker rm $HOSTNAME-docker >/dev/null 2>&1
echo "Start a new one"
docker run --name="${HOSTNAME}-docker" \
  -e HOST=$HOST \
  -e PORT=$PORT \
  -e NAME=simplewebapp-docker \
  -d \
  -p ${PORT}:8000 \
  simple_webapp_python
