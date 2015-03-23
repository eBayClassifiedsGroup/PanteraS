openvpn:
  name: openvpn
  image: ${REGISTRY}openvpn
  privileged: true
  volumes:
    ${OPENVPN_VOL}
  net: host
