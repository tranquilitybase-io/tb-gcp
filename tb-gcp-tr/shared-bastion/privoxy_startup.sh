#!/bin/bash -xe

# output to log file

echo "metadata_start"

sudo apt install -y git
sudo update -y

sudo install -y privoxy
systemctl enable privoxy
systemctl start privoxy

echo "metadata_end"