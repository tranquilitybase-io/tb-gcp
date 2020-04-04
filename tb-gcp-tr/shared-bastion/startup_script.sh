#!/bin/bash -xe

echo "metadata_start"

sudo apt update
sudo apt -y install squid
sudo systemctl start squid
sudo systemctl enable squid

echo "metadata_end"
