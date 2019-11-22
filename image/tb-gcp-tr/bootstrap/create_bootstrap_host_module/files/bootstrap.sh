exec >> /var/log/bootstrap.log 2>&1

# configure stackdriver logging
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash ./install-logging-agent.sh
cat <<EOF > /etc/google-fluentd/config.d/bootstrap-log.conf
<source>
    @type tail
    # Format 'none' indicates the log is unstructured (text).
    format none
    # The path of the log file.
    path /var/log/bootstrap.log
    # The path of the position file that records where in the log file
    # we have processed already. This is useful when the agent
    # restarts.
    pos_file /var/lib/google-fluentd/pos/bootstrap-log.pos
    read_from_head true
    # The log tag for this log input.
    tag bootstrap-log
</source>
EOF
systemctl restart google-fluentd
export HOME=/root
wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
apt-get update
apt-get install unzip
unzip terraform_0.11.13_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_0.11.13_linux_amd64.zip
apt-get -y install git
apt-get install -y kubectl
cd /tmp
git clone --branch ${lz_branch} https://aadfef28824f0ea635adbfafd75468bd1c4cac44:aadfef28824f0ea635adbfafd75468bd1c4cac44@github.com/tranquilitybase-io/tb-gcp-tr.git
cd /tmp/tb-gcp-tr/landingZone
cat <<EOF > input.auto.tfvars
tb_discriminator = "${tb_discriminator}"
terraform_state_bucket_name = "${terraform_state_bucket_name}"
EOF
terraform init -backend-config="bucket=${terraform_state_bucket_name}" -backend-config="prefix=landingZone"
terraform apply -var-file input.tfvars -auto-approve
cd /tmp
gcloud source repos create tb-terraform-code
gcloud source repos clone tb-terraform-code
cd /tmp/tb-terraform-code
cp /tmp/tb-gcp-tr/landingZone/main.tf main.tf
cp /tmp/tb-gcp-tr/landingZone/input.tfvars input.tfvars
cp /tmp/tb-gcp-tr/landingZone/input.auto.tfvars input.auto.tfvars
git init
git add .
git commit -m "Landing zone terraform script"
git push -u origin master
