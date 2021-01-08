#!/bin/bash

#install terragrunt
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.27.0/terragrunt_linux_amd64
chmod u+x terragrunt_linux_amd64
mv terragrunt_linux_amd64 terragrunt
sudo mv terragrunt /usr/local/bin/terragrunt
sudo terragrunt --version

#random number
RND="$(tr -dc 'a-z0-9' < /dev/urandom | fold -w 8 | sed '/^[0-9]*$/d' | head -n 1)"

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

echo '{ "project_id": "'${TBASE_PROJECT_NAME}'", "folder_name": "'${TBASE_FOLDER_NAME}'", "TG_STATE_BUCKET": "'${TG_STATE_BUCKET_NAME}'", "TG_PROJECT": "'${TBASE_PROJECT_NAME}'"  }' \
| jq '.' > ./01-bootstrap/fp.auto.tfvars.json

cd ./01-bootstrap
#sudo terragrunt init --terragrunt-non-interactive
#sudo terragrunt apply -auto-approve --terragrunt-non-interactive
echo "Bootstrap apply completed successfully"
