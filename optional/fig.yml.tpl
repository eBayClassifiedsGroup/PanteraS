openvpn:
  image: ${REGISTRY}openvpn
  privileged: true
  volumes:
    ${OPENVPN_VOL}
  ports:
    - "1194:1194"
    - "1194:1194/udp"
  hostname: ${HOSTNAME}-openvpn
  name: openvpn
  net: host
