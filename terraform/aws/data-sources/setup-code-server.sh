#!/bin/bash

# Download RPM Dependencies for Code Server
curl http://download-ib01.fedoraproject.org/pub/fedora/linux/updates/29/Everything/x86_64/Packages/l/libstdc++-8.3.1-2.fc29.x86_64.rpm -o /tmp/libstdc++-8.3.1-2.fc29.x86_64.rpm
curl http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/28/Everything/x86_64/Packages/g/glibc-common-2.27-38.fc28.x86_64.rpm -o /tmp/glibc-common-2.27-38.fc28.x86_64.rpm
curl http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/28/Everything/x86_64/Packages/g/glibc-2.27-38.fc28.x86_64.rpm -o /tmp/glibc-2.27-38.fc28.x86_64.rpm
curl http://archives.fedoraproject.org/pub/archive/fedora/linux/updates/28/Everything/x86_64/Packages/g/glibc-langpack-en-2.27-38.fc28.x86_64.rpm -o /tmp/glibc-langpack-en-2.27-38.fc28.x86_64.rpm
sudo rpm -ivh --force /tmp/*.rpm

# Download and install Code Server
curl -L https://github.com/cdr/code-server/releases/download/1.939-vsc1.33.1/code-server1.939-vsc1.33.1-linux-x64.tar.gz -o /tmp/code-server1.939-vsc1.33.1-linux-x64.tar.gz
tar xf /tmp/code-server1.939-vsc1.33.1-linux-x64.tar.gz -C /tmp
sudo mv /tmp/code-server1.939-vsc1.33.1-linux-x64/code-server /usr/local/bin/

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