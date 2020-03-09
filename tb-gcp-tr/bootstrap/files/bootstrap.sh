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

MAX_ATTEMPTS=10
DELAY_BETWEEN_ATTEMPTS=60

export HOME=/root
apt-get -y install git
apt-get -y install kubectl

enable_itop="${enable_itop}"

if [ "$enable_itop" == "true" ]
then
  cd /opt/tb/repo/tb-gcp-tr/landingZone/with-itop/
else
  cd /opt/tb/repo/tb-gcp-tr/landingZone/no-itop/
fi

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

apply_failures=0
while [ $apply_failures -lt $MAX_ATTEMPTS ]; do
  terraform apply -var-file input.tfvars -auto-approve
  if [ $? -eq 0 ]; then
    echo "Landing Zone successfully deployed."
    break
  fi
  if [ $((apply_failures +1)) -eq $MAX_ATTEMPTS ]; then
    echo "Maximum of $MAX_ATTEMPTS reached. Moving on..."
    break
  fi
  echo "Landing Zone deployment failed."
  apply_failures=$(($apply_failures + 1))
  echo "Retry #$apply_failures starting in $DELAY_BETWEEN_ATTEMPTS seconds."
  sleep $DELAY_BETWEEN_ATTEMPTS
done

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
