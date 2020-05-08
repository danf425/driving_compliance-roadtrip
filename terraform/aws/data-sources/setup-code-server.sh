#!/bin/bash

# Download and install Code Server
curl -L https://github.com/cdr/code-server/releases/download/3.1.1/code-server-3.1.1-linux-x86_64.tar.gz -o /tmp/code-server-3.1.1-linux-x86_64.tar.gz
tar xf /tmp/code-server-3.1.1-linux-x86_64.tar.gz -C /tmp
sudo mv /tmp/code-server-3.1.1-linux-x86_64/ /usr/local/bin/code-server/

# Install Code Server service
sudo mv /tmp/code-server.service /etc/systemd/system/code-server.service

# Provision Settings file for code server
sudo mkdir -p /home/chef/.local/share/code-server/User
sudo mv /tmp/code-server-settings.json /home/chef/.local/share/code-server/User/settings.json
sudo chown -R chef:chef /home/chef/.local

# Enable Code Server
sudo systemctl daemon-reload
sudo systemctl start code-server
sudo systemctl enable code-server

# rebuild rpm and yum database
sudo rpm --rebuilddb
sudo yum clean all
