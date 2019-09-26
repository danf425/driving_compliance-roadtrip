#!/bin/bash

set -eu -o pipefail

# export workstation_password

# Yum Update, Install Tree
sudo yum update --assumeyes --quiet
sudo yum install --assumeyes --quiet tree yum-utils epel-release

# Install modern Git
sudo rpm -U https://centos7.iuscommunity.org/ius-release.rpm
# sudo yum install --assumeyes --quiet git2u-all

# Install Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install --assumeyes --quiet yum-utils device-mapper-persistent-data lvm2 docker-ce
sudo systemctl enable docker
sudo systemctl start docker

# Add Chef User in Wheel, Root & Docker Groups. No password for sudo
sudo useradd chef -G wheel,root,docker
sudo sh -c "echo 'chef ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"
echo $1 | sudo passwd chef --stdin
sudo sed -i "/^PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo systemctl restart sshd.service