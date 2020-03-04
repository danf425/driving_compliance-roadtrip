#!/bin/bash

set -eu -o pipefail

# Yum Update, Install Tree
sudo yum update --assumeyes --quiet

# Add nano editor
sudo yum install nano --assumeyes --quiet

# Install latest version of Chef Workstation
curl -LO https://omnitruck.chef.io/install.sh && sudo bash ./install.sh -P chef-workstation && rm install.sh

# Start Docker

sudo systemctl enable docker
sudo systemctl start docker

# Add Chef User in Wheel, Root & Docker Groups. No password for sudo
sudo useradd chef -G wheel,root,docker
sudo sh -c "echo 'chef ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"
echo $1 | sudo passwd chef --stdin
sudo sed -i "/^PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd.service
