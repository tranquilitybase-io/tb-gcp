args=("$@")

PROJECT_ID=${args[0]}
BILLING_ID=${args[1]}
SA_EMAIL=${args[2]}
FOLDER_ID=${args[3]}

echo $PROJECT_ID
echo $BILLING_ID
echo $SA_EMAIL
echo $FOLDER_ID

#Add permissions at the project level
echo "Adding permissions at the project level... "
gcloud projects add-iam-policy-binding "${PROJECT_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/compute.instanceAdmin.v1 --format=none

# Add permissions at the folder level
echo "Adding permissions at the folder level..."
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/resourcemanager.folderAdmin --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/resourcemanager.projectCreator --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/resourcemanager.projectDeleter --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/billing.projectManager --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/compute.networkAdmin --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/compute.xpnAdmin --format=none
gcloud resource-manager folders add-iam-policy-binding "${FOLDER_ID}" --member=serviceAccount:"${SA_EMAIL}" --role=roles/owner --format=none

# Add permissions at the billing level
echo "Adding permissions at the billing account level..."
gcloud beta billing accounts get-iam-policy "${BILLING_ID}" > billing.yaml
sa="\ \ - serviceAccount:${SA_EMAIL}"
sed "/billing.admin/i ${sa}" billing.yaml > billing2.yaml
gcloud beta billing accounts set-iam-policy "${BILLING_ID}" billing2.yaml --format=none
rm billing.yaml billing2.yaml