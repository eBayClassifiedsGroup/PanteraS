docker kill haproxy
docker rm haproxy
docker run -d -p 80:80 -p 9081:81 -p 9082:82 --name=haproxy \
  -h haproxy -v /opt:/haproxy-override haproxy \
  -addr=paas44-1.mobile.rz:8500 \
  -backend "c=consul@44_Integra_229:8500" \
  -backend "s=SimplePython@44_Integra_229" \
  -reload "reload haproxy"
