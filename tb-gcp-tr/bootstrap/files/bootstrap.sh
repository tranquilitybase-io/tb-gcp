#!/bin/bash
# Copyright 2019 The Tranquility Base Authors
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

exec >> /var/log/bootstrap.log 2>&1

export HOME=/root
apt-get -y install git
apt-get -y install kubectl

cd /opt/tb/repo/tb-gcp-tr/landingZone/
cat <<EOF > input.auto.tfvars
clusters_master_whitelist_ip = "${clusters_master_whitelist_ip}"
region = "${region}"
region_zone = "${region_zone}"
root_id = "${root_id}"
root_is_org = "${root_is_org}"
billing_account_id = "${billing_account_id}"
tb_discriminator = "${tb_discriminator}"
terraform_state_bucket_name = "${terraform_state_bucket_name}"
EOF
terraform init -backend-config="bucket=${terraform_state_bucket_name}" -backend-config="prefix=landingZone"
terraform apply -var-file input.tfvars -auto-approve

# Commit current TB terraform code to GCR
cd /tmp
gcloud source repos create tb-terraform-code
gcloud source repos clone tb-terraform-code
cd /tmp/tb-terraform-code
rsync -a /opt/tb/repo/ .
git init
git add .
git commit -m "Landing zone terraform script"
git push -u origin master
