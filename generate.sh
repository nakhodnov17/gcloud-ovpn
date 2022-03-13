# Generate configuration files. Use root certificate password
OVPN_DATA="ovpn-data-persistent"
declare -a TARGET_CLIENTS=( "nakhodnov17_note10" "nakhodnov17_tab8" "aredosbyk_llpc" "aredosbyk_op9p" )
for TARGET_CLIENT in ${TARGET_CLIENTS[@]}; do
    sudo docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full ${TARGET_CLIENT} nopass
    sudo docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient ${TARGET_CLIENT} > ${TARGET_CLIENT}.ovpn
done
