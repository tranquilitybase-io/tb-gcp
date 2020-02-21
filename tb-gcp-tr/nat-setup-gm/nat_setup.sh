#!/bin/bash
set -e

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

terraform init

terraform apply -var-file input.tfvars -auto-approve

#echo "Cleaning up..."
#echo
#echo "disabling external IP address"
#access_config_name=$(gcloud compute instances describe $INSTANCE_NAME --zone $ZONE --format yaml --flatten="networkInterfaces[].accessConfigs[].name" | sed -n '2p')
#
#echo "$access_config_name"
#gcloud beta compute instances delete-access-config "$INSTANCE_NAME" --access-config-name "${access_config_name}" --zone $ZONE

echo
echo "Deploying Landing Zone"
nat_ip_name="$PREFIX-vpc-network-nat-gateway-ip"

white_list_ip=$(gcloud compute addresses list --filter name:"$nat_ip_name" --format="value(address)")

cd /opt/tb/repo/tb-gcp-tr/landingZone/no-itop

echo "clusters_master_whitelist_ip=\"${white_list_ip}\"" >> input.auto.tfvars

source input.auto.tfvars

terraform init -backend-config="bucket=${terraform_state_bucket_name}" -backend-config="prefix=landingZone"

terraform apply -var-file input.tfvars -auto-approve


