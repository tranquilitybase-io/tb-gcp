#!/bin/bash
set -e

function print_help {
	echo "Usage: $0 <arguments>"
	echo
	echo "-r, --region <id>		(REQUIRED) Region"
	echo "-z, --zone <id>		(REQUIRED) Zone"
	echo "-v, --vpc_name <string>		(REQUIRED) Bootstrap VPC name"
	echo
}

REGION=""
ZONE=""
VPC_NAME=""

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

if [[ -z ${REGION} || -z ${ZONE} || -z ${VPC_NAME} ]]; then
	echo "ERROR: Invalid arguments."
	echo
	print_help
	exit 1
fi

echo $REGION
echo $ZONE
echo $VPC_NAME

cd /opt/tb/repo/tb-gcp-tr/nat-setup-gm

PROJECT_ID=$(curl "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
INSTANCE_NAME=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/name" -H "Metadata-Flavor: Google")

cat <<EOF > input.tfvars
region = "${REGION}"
project_id = "${PROJECT_ID}"
router_name = "vpc-network-router"
router_nat_name = "vpc-network-nat-gateway"
vpc_name = "${VPC_NAME}"

EOF

terrform init

# uncomment when whole script working
# terraform apply -var-file input.tfvars -auto-approve

echo "Cleaning up..."
echo
echo "Removing a temporary firewall rule"
gcloud compute firewall-rules delete allow-ssh -q

echo
echo "disabling external IP address"
gcloud beta compute instances delete-access-config  $INSTANCE_NAME --access-config-name "External NAT" --zone $ZONE

