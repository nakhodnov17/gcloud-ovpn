gcloud components install alpha

# Define name for your project
PROJECT_ID=vpn-mmp-main
# Here we get first billing account ID. You can set BA by youself from list of all accounts: "gcloud alpha billing accounts list"
BILLING_ACCOUNT=$(gcloud alpha billing accounts list | grep -Po "(.*-.*-[^\s]+)") | sed -n 1p
# Region for static IP
REGION=us-central1
# Zone for VM instance and drive
ZONE=us-central1-a
# ssh username on VM
SSH_USERNAME=nakhodnov17

gcloud projects create ${PROJECT_ID} --name "Custom VPN for MMP"
gcloud config set project ${PROJECT_ID}

# Enable billing for new project and create budget with notifications
gcloud alpha billing projects link ${PROJECT_ID} --billing-account=${BILLING_ACCOUNT}
gcloud services enable billingbudgets.googleapis.com
gcloud billing budgets create --billing-account=${BILLING_ACCOUNT} \
    --display-name="VPN budget" --budget-amount=10.00USD --filter-projects=projects/${PROJECT_ID} \
    --threshold-rule="percent=0.50,basis=current-spend" \
    --threshold-rule="percent=0.75,basis=current-spend" \
    --threshold-rule="percent=0.75,basis=forecasted-spend" \
    --threshold-rule="percent=1.00,basis=current-spend" \
    --threshold-rule="percent=1.00,basis=forecasted-spend"

gcloud services enable compute.googleapis.com

# Create network with static IP
gcloud compute addresses create vpn-static-ip \
    --description="Static IP for VPN server" \
    --network-tier=STANDARD \
    --region=${REGION}

# Create persistent boot drive
# You can choose other images from list: "gcloud compute images list"
gcloud compute disks create vpn-server-drive \
    --description="Persistent boot disk for VPN server" \
    --size=20GB --type=pd-standard --zone=${ZONE} \
    --image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2110-impish-v20220203

# Create server instance
# You can choose other machine types from list: "gcloud compute machine-types list"
gcloud compute instances create vpn-server \
    --zone=${ZONE} \
    --address=vpn-static-ip \
    --network-tier STANDARD \
    --disk="name=vpn-server-drive,boot=yes" \
    --description="VPN server instance" \
    --machine-type=e2-micro \
    --tags="vpn,server"

# Create ssh key pair (this command DO NOT owerride existing key)
ssh-keygen -b 2048 -C "SSH key for MMP VPN server by ${SSH_USERNAME}@gmail.com" -t rsa -f ~/.ssh/id_rsa_gcloud_vpn_mmp
echo "${SSH_USERNAME}:$(cat ~/.ssh/id_rsa_gcloud_vpn_mmp.pub)" > ssh_metadata.txt

# Add public ssh key for instance
gcloud compute instances add-metadata vpn-server \
    --metadata-from-file ssh-keys=ssh_metadata.txt

# Open vpn trafic on server
gcloud compute firewall-rules create vpn-static-ip-udp-1194 \
    --description="Allow vpn trafic on port 1194 for vpn-static-ip" \
    --allow udp:1194 --target-tags="vpn,server" --source-ranges=0.0.0.0/0

# Get server external IP
IP=$(gcloud compute addresses describe vpn-static-ip --region=us-central1 2> /dev/null | grep -Po ".*address: \K([0-9]*.[0-9]*.[0-9]*.[0-9]*)")

# Upload setup files on server
scp -i ~/.ssh/id_rsa_gcloud_vpn_mmp {run.sh,setup.sh,generate.sh} ${SSH_USERNAME}@${IP}:/home/${SSH_USERNAME}/

