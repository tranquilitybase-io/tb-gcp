#!/bin/bash -xe

# output to log file

echo "metadata_start"

curl -sLO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl version --client=true

sudo apt install -y git
sudo update -y

sudo install -y privoxy
systemctl enable privoxy
systemctl start privoxy

echo "metadata_end"