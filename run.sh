# Initialize server
OVPN_DATA="ovpn-data-persistent"
IP=$(curl -s https://api.ipify.org)
sudo docker volume create --name ${OVPN_DATA}
sudo docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://${IP}
# Here you must setup root certificate password and root user. It should be used in order to produce client configs
sudo docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

# Run server
sudo docker run -v ${OVPN_DATA}:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
