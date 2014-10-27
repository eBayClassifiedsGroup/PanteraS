SimpleWebappPython:
  image: simple_webapp_python 
  environment:
    NAME: simplewebapp-fig
    PORT: 8001
    HOST: $HOSTNAME
  ports:
    - "8001:8000"
