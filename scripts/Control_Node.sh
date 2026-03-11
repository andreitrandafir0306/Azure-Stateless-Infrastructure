#!/bin/bash

# For manual configuration

ssh -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ansible-tower@$Master_IP << 'EOF'
chmod u+x Docker_Ansible_Install.sh
./Docker_Ansible_Install.sh
export ANSIBLE_REMOTE_USER="managed-node"
export ANSIBLE_PRIVATE_KEY_FILE="$HOME/.ssh/dcli_rsa"
export ANSIBLE_HOST_KEY_CHECKING="False"
sudo apt update -y && sudo apt upgrade -y && sudo apt install -y python3-pip
ansible-galaxy collection install azure.azcollection --force
ansible-galaxy collection install community.docker --force
pip3 install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements.txt --break-system-packages 
pip3 install docker
ansible-playbook asi_playbook.yaml -i inventory.azure_rm.yaml
EOF



