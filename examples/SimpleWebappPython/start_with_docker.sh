PORT=8000
ID=web1
NAME=SimpleWebappPython
SCRIPT='wget -q http://${HOSTNAME}.mobile.rz:${PORT}/cgi-bin/index'

echo "Clean up previous example"
docker kill $HOSTNAME-${ID} >/dev/null 2>&1
docker rm $HOSTNAME-${ID} >/dev/null 2>&1
echo "Start a new one"
docker run --name="${HOSTNAME}-${ID}" -h "${HOSTNAME}-${ID}" -d -p ${PORT}:8000 simple_webapp_python
