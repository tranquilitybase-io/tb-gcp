#!/bin/bash

#random number
RND="$(tr -dc 'a-z0-9' < /dev/urandom | fold -w 8 | sed '/^[0-9]*$/d' | head -n 1)"

#Build folder/project name
TG_STATE_BUCKET_PREFIX="tg-tfstate-"
TBASE_FOLDER_PREFIX="TranquilityBase-"
TBASE_PROJECT_PREFIX="bootstrap-"
TBASE_FOLDER_NAME="${TBASE_FOLDER_PREFIX}${RND}"
TBASE_PROJECT_NAME="${TBASE_PROJECT_PREFIX}${RND}"
TG_STATE_BUCKET="${TG_STATE_BUCKET_PREFIX}${RND}"

#create root TB folder
TBASE_FOLDER_ID=$(gcloud resource-manager folders create --display-name="${TBASE_FOLDER_NAME}" --folder="${TBASE_PARENT_FOLDER_ID}" --format="value(name.basename())")

#create bootstrap project
gcloud projects create "${TBASE_PROJECT_NAME}" --folder="${TBASE_FOLDER_ID}"

#define variables for bootstrap backend
export TG_STATE_BUCKET=${TG_STATE_BUCKET}
export TG_PROJECT=${TBASE_PROJECT_NAME}

echo '{ "project_id": "'${TBASE_PROJECT_NAME}'", "folder_name": "'${TBASE_FOLDER_NAME}'"  }' | jq '.' > ./01-bootstrap/fp.auto.tfvars.json

cd ./01-bootstrap
#terragrunt init --terragrunt-non-interactive
#terragrunt apply -auto-approve --terragrunt-non-interactive
echo "Bootstrap apply completed successfully"
