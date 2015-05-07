This example shows how to start containers, stable and canaries.  
You can scale them up and down smootly with taking out from loadbalancer.

First build image:
```
./build-docker-image.sh
```
Each plan contains simple python http server on 8080,
but running inside container with wrapper script.

Deploy "stable" example:
```
$ IP=<IP> ./start_with_marathon.sh deploy0_marathon.json
```

Deploy  "canaries" example:
```
$ IP=<IP> ./start_with_marathon.sh deploy1_marathon.json
```

Test:
```
$ while true; do curl -H 'Host: python-smooth.service.consul' http://<IP>; done
```

scale up and down in marathon GUI http://<IP>:8080  
and check that there is no connection timeout or connectin error,  
so removed containers goes into mainanece mode before being killed.
