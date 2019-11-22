#!/bin/bash -xe

apt-get update
apt-get upgrade -y
apt-get install -y vim htop python3-pip python3-virtualenv traceroute dnsutils kubectl
apt autoremove -y
