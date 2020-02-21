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

#set -e

function print_help {
	echo "Usage: $0 <arguments>"
	echo
	echo "-r, --region <id>		(REQUIRED) Region"
	echo "-z, --zone <id>		(REQUIRED) Zone"
	echo "-v, --vpc_name <string>		(REQUIRED) Bootstrap VPC name"
	echo "-d, --deployment <string>		(REQUIRED) deployment prefix"
	echo
}

REGION=""
ZONE=""
VPC_NAME=""
PREFIX=""
MAX_ATTEMPTS=10
DELAY_BETWEEN_ATTEMPTS=60

while (( "$#" )); do
  case "$1" in
    -r|--region)
      REGION=$2
      shift 2
      ;;
    -z|--zone)
      ZONE=$2
      shift 2
      ;;
    -h|--help)
      print_help
      exit 0
      ;;
    -v|--vpc)
      VPC_NAME=$2
      shift 2
      ;;
    -d|--deployment)
      PREFIX=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # unsupported positional arguments
      echo "Error: Unsupported positional argument $1" >&2
      shift
      ;;
  esac
done

if [[ -z ${REGION} || -z ${ZONE} || -z ${VPC_NAME} || -z ${PREFIX} ]]; then
	echo "ERROR: Invalid arguments."
	echo
	print_help
	exit 1
fi

echo $REGION
echo $ZONE
echo $VPC_NAME
echo $PREFIX

router_n="$PREFIX-vpc-network-router"
router_nat_n="$PREFIX-vpc-network-nat-gateway"
fw_n="$PREFIX-allow-iap-ingress-ssh"

cd /opt/tb/repo/tb-gcp-tr/nat-setup-gm

PROJECT_ID=$(curl "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")

cat <<EOF > input.tfvars
region = "${REGION}"
project_id = "${PROJECT_ID}"
router_name = "${router_n}"
router_nat_name = "${router_nat_n}"
vpc_name = "${VPC_NAME}"
fw_name = "${fw_n}"
EOF

echo "Deploying Router and Cloud NAT"#
terraform apply -var-file input.tfvars -auto-approve

echo
echo "Deploying Landing Zone"
cd /opt/tb/repo/tb-gcp-tr/landingZone/no-itop

#retrieve Cloud NAT IP
nat_ip_name="$PREFIX-vpc-network-nat-gateway-ip"
white_list_ip=$(gcloud compute addresses list --filter name:"$nat_ip_name" --format="value(address)")
echo "clusters_master_whitelist_ip=\"${white_list_ip}\"" >> input.auto.tfvars

source input.auto.tfvars


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

  #restablish state
  rm -r .terraform/
  gsutil -m rm gs://${terraform_state_bucket_name}/**
  terraform init -backend-config="bucket=${terraform_state_bucket_name}" -backend-config="prefix=landingZone"
  sleep $DELAY_BETWEEN_ATTEMPTS
done


