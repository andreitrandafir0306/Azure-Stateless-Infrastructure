#!/bin/bash

touch .hushlogin && scp -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ~/.hushlogin ansible-tower@$Master_IP:~/.hushlogin
scp -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ~/.ssh/dcli_rsa ansible-tower@$Master_IP:~/.ssh/dcli_rsa
scp -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ./ansible/asi_playbook.yaml ansible-tower@$Master_IP:~/asi_playbook.yaml
scp -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ./ansible/inventory.azure_rm.yaml ansible-tower@$Master_IP:~/inventory.azure_rm.yaml
scp -i ~/.ssh/dcli_rsa -o StrictHostKeyChecking=no -q ./scripts/Docker_Ansible_Install.sh ansible-tower@$Master_IP:~/Docker_Ansible_Install.sh