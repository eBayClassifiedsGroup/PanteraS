PORT=8000
ID=web1
NAME=SimpleWebappPython
SCRIPT='wget -q http://${HOSTNAME}.mobile.rz:${PORT}/cgi-bin/index'

docker kill $HOSTNAME-web1
docker rm $HOSTNAME-web1
docker run --name="${HOSTNAME}-web1" -h "${HOSTNAME}-web1" -d -p ${PORT}:8000 simple_webapp_python
