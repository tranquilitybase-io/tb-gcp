#!/bin/bash
set -e
init()
{
  echo "Welcome to Tranquility Base! We will take you through the configurations required to deploy the Landing Zone."
  echo
  echo "Before we proceed any further, please make sure you're authenticated to gcloud with elevated permissions, if not, exit (CTRL+C) and execute 'gcloud auth login' to do so."
  echo
  echo "In order to deploy the Landing Zone, we will need to: "
  echo
  echo "1: Create the Service account with appropriate permissions and access to APIs (For more info: https://github.com/tranquilitybase-io/tb-gcp#service-account-creation)."
  echo "2: If you already have a service account then you can go ahead and deploy the Landing Zone by running: 'get_started.sh deploy-lz' "
  echo
  echo "Press 1 to create the service account or Press 2 to deploy the Landing Zone: "

  read varname

  if [ $varname == "1" ]
  then
     create_service_account
  elif [ $varname == "2" ]
  then
     deploy_landing_zone
  else
     echo "Invalid arguments"
     echo "Aborting..."
     exit 0
  fi
}

# bash get-started.sh -create-sa
create_service_account()
{
  echo "Enter the parent folder id of the project: "
  read folder_id
  FOLDER_ID=$folder_id

  echo "Enter the Billing ID: "
  read billing_id
  BILLING_ID=$billing_id

  PROJECT_ID=$(curl "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")

    # Create a service account
  gcloud --project ${PROJECT_ID} iam service-accounts create tb-bootstrap-builder
  gcloud --project ${PROJECT_ID} iam service-accounts keys create tb-bootstrap-builder.json --iam-account tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com


  gcloud beta billing accounts get-iam-policy ${BILLING_ID} > billing.yaml

  sa="\ \ - serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com"
  sed "/billing.admin/i ${sa}" billing.yaml > billing2.yaml

  gcloud beta billing accounts set-iam-policy ${BILLING_ID} billing2.yaml

  gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.xpnAdmin

  gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.folderAdmin

  gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.projectCreator

  gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.instanceAdmin.v1


  echo "Activating essential APIs"
  gcloud --project ${PROJECT_ID} services enable compute.googleapis.com
  gcloud --project ${PROJECT_ID} services enable cloudresourcemanager.googleapis.com
  gcloud --project ${PROJECT_ID} services enable cloudbilling.googleapis.com
  gcloud --project ${PROJECT_ID} services enable iam.googleapis.com
  gcloud --project ${PROJECT_ID} services enable serviceusage.googleapis.com
  gcloud --project ${PROJECT_ID} services enable storage-api.googleapis.com


    gcloud auth activate-service-account tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --key-file=tb-bootstrap-builder.json

    echo "GOOGLE_CREDENTIALS=$(pwd)/tb-bootstrap-builder.json" >> ~/.profile
    source ~/.profile

    cd /opt/tb/repo/tb-gcp-tr/landingZone/no-itop/

    echo "root_id=${FOLDER_ID}" >> input.auto.tfvars
    echo "billing_account_id='${BILLING_ID}'" >> input.auto.tfvars

    cd
    echo "You're now ready to deploy the Landing zone!"
    echo
}

# bash get-started.sh -deploy-lz
deploy_landing_zone()
{

  MAX_ATTEMPTS=10
  DELAY_BETWEEN_ATTEMPTS=60

  cd /opt/tb/repo/tb-gcp-tr/landingZone/no-itop/

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
    sleep $DELAY_BETWEEN_ATTEMPTS
  done
}

print_help()
{
  echo "List of supported commands: "
  echo "'get_started.sh init': Run this to get started and to create the service service account or deploy the Landing Zone"
  echo "'get_started.sh create-sa' Run this to create the service account"
  echo "'get_started.sh deploy-lz' Run this to deploy the Landing Zone"
}

argument=$1

if [ $argument == "init" ]
then
  init
elif [ $argument == "deploy-lz" ]
then
  deploy_landing_zone
elif [ $argument == "create-sa" ]
then
  create_service_account
elif [ $argument == "-help" ]
then
  print_help
else
  print_help
fi
