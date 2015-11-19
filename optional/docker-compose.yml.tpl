openvpn:
  image: ${REGISTRY}panteras/openvpn
  privileged: true
  volumes:
    ${OPENVPN_VOL}
  net: host
