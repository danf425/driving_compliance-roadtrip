#!/bin/bash

# Enable Password SSH
sudo sed -i "s/^\(ssh_pwauth:[[:space:]]*\)0/\11/" /etc/cloud/cloud.cfg
