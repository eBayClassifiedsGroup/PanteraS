This example shows how to start containers, stable and canaries.

Each plan contains simple python http server on 8080.  
Deploy "stable" example:
```
$ IP=<IP> ./start_with_marathon.sh deploy0_marathon.json
```

Deploy  "canaries" example (with additional routes):
```
$ IP=<IP> ./start_with_marathon.sh deploy1_marathon.json
```

Test:
```
$ curl -H 'Host: python.service.consul' http://<IP>
```


Deploy  "tcp" example:
```
$ IP=<IP> ./start_with_marathon.sh deploy2_marathon.json
```

Test:
```
$ curl http://<IP>:5556
```
