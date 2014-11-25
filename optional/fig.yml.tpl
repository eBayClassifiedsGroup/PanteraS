dns:
  environment:
    MASTER_IP: $IP
  privileged: true
  image: dnsmasq
  name: dnsmasq
  net: host
