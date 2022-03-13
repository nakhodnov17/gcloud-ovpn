SSH_USERNAME=nakhodnov17
IP=$(gcloud compute addresses describe vpn-static-ip --region=us-central1 2> /dev/null | grep -Po ".*address: \K([0-9]*.[0-9]*.[0-9]*.[0-9]*)")

# Get open vpn configuration files from server
declare -a TARGET_CLIENTS=( "nakhodnov17_note10" "nakhodnov17_tab8" "aredosbyk_llpc" "aredosbyk_op9p" )
for TARGET_CLIENT in ${TARGET_CLIENTS[@]}; do
    scp -i ~/.ssh/id_rsa_gcloud_vpn_mmp ${SSH_USERNAME}@${IP}:/home/${SSH_USERNAME}/${TARGET_CLIENT}.ovpn ./configs/${TARGET_CLIENT}.ovpn
done
