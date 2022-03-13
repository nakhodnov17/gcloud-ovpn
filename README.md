# gcloud-ovpn
Fast configuration for OpenVPN server on Google Cloud

Before start you should carefully check ENV variables. For example you must provide unique `PROJECT_ID` in `gcloud_creation.sh`. Also you should change `TARGET_CLIENTS` list in `generate.sh` and `get_configs.sh`. Optionally you can provide other `SSH_USERNAME` in `gcloud_creation.sh` and `get_configs.sh` (and at step 2).

1. Setup your Google Cloud account and create VM instance with all settings (you will need to setup passphrase for ssh key and then use it):
    ```bash
    bash gcloud_creation.sh
    ```
2. Connect to the server:
    ```bash
    SSH_USERNAME=nakhodnov17
    IP=$(gcloud compute addresses describe vpn-static-ip --region=us-central1 2> /dev/null | grep -Po ".*address: \K([0-9]*.[0-9]*.[0-9]*.[0-9]*)")
    ssh ${SSH_USERNAME}@${IP} -i ~/.ssh/id_rsa_gcloud_vpn_mmp
    ```
3. Install necessary libraries on server and then reboot it:
    ```bash
    bash setup.sh
    reboot
    ```
4. Then start OVPN instance on server and generate client configs:
    ```bash
    # Here you must setup root certificate password and root user. It should be used in order to produce client configs
    bash run.sh
    # Generate configuration files. Use root certificate password
    bash generate.sh
    ```
5. Download configs to the host (use the ssh key passphrase):
    ```bash
    bash get_configs.sh
    ```
