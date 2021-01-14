#!/bin/bash

#install terragrunt
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.27.0/terragrunt_linux_amd64
chmod u+x terragrunt_linux_amd64
mv terragrunt_linux_amd64 terragrunt
sudo mv terragrunt /usr/local/bin/terragrunt
sudo terragrunt --version

#install terraform
wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
unzip terraform_0.13.4_linux_amd64.zip
sudo mv ./terraform /usr/local/bin/
rm terraform_0.13.4_linux_amd64.zip
terraform --version

#random number
RND=$RANDOM

#Build folder/project name
TG_STATE_BUCKET_PREFIX="tg-tfstate-"
TBASE_FOLDER_PREFIX="TranquilityBase-"
TBASE_PROJECT_PREFIX="bootstrap-"
TBASE_FOLDER_NAME="${TBASE_FOLDER_PREFIX}${RND}"
TBASE_PROJECT_NAME="${TBASE_PROJECT_PREFIX}${RND}"
TG_STATE_BUCKET_NAME="${TG_STATE_BUCKET_PREFIX}${RND}"

#create root TB folder
TBASE_FOLDER_ID=$(gcloud resource-manager folders create --display-name="${TBASE_FOLDER_NAME}" --folder="${TBASE_PARENT_FOLDER_ID}" --format="value(name.basename())")

#create bootstrap project
gcloud projects create "${TBASE_PROJECT_NAME}" --folder="${TBASE_FOLDER_ID}"

#linking project to billing account
gcloud alpha billing projects link "${TBASE_PROJECT_NAME}" --billing-account "${TBASE_BILLING_ID}" --format=none

#used as vars for bootstrap
export project_id=${TBASE_PROJECT_NAME}
export folder_id=${TBASE_FOLDER_ID}
export region=${TBASE_REGION}
export billing_id=${TBASE_BILLING_ID}

#used in terragrunt backend
export TF_VAR_PROJECT_ID=${TBASE_PROJECT_NAME}
export TF_VAR_REGION=${TBASE_REGION}
export TF_VAR_STATE_BUCKET_NAME=${TG_STATE_BUCKET_NAME}

cd ./01-bootstrap

terragrunt init --terragrunt-non-interactive
terragrunt apply -auto-approve --terragrunt-non-interactive
echo "Bootstrap apply completed successfully"
