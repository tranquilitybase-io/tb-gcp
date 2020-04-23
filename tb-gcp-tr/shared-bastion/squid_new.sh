#!/bin/bash -xe

# output to log file
exec >> /var/log/bootstrap.log 2>&1

echo "metadata_start"

curl -sLO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
kubectl version --client=true

yum install -y git htop vim squid

# Add IAP source CIDR
echo "acl localnet src 35.235.240.0/20" | tee -a /etc/squid/squid.conf

systemctl enable squid
systemctl start squid

echo "metadata_end"
