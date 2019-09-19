# Tranquility Base

Hi, and welcome to Tranquility Base - the open source multi-cloud infrastructure-as-code Landing Zone together with a self-service portal for automating the provisioning of a set of DevOps-ready reference architectures. 

The current version is feature complete for this release but we are aware there will be bugs to be fixed and patches to be made. For example there will be security improvements to be made and we are working to identify and update the codebase to address them. 

If you want to help us with this or contribute to Tranquility Base in general please contact us on [contact@tranquilitybase.io]

## Example Deployment instructions

The following instructions assumes that:
* a project exists to host a service account which is used to deploy Tranquility Base;
* a billing account which is used on all projects that will be created;


### Initial setup:

* Clone the repository:

```
git clone git@github.com:tranquilitybase-io/tb-gcp.git
cd tb-gcp
```

* Setup environment variables to help through the deployment process:

``` bash
PROJECT_ID=<project_id>
BILLING_ACCOUNT=<billing_account_id>
```

### Service Account Creation

* Create a service account which will be used during the initial deployment process:

```
gcloud --project ${PROJECT_ID} iam service-accounts create tb-executor-0000
gcloud --project ${PROJECT_ID} iam service-accounts keys create tb-executor-000.json --iam-account tb-executor-0000@${PROJECT_ID}.iam.gserviceaccount.com
```

* Give the new service account the ability to link projects to the billing account.

```
gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT} > billing.yaml
```

* Edit `billing.yaml` and add the following entry to the existing bindings (replace `PROJECT_ID` below before saving):

``` yaml
members:
- serviceAccount:tb-executor-0000@PROJECT_ID.iam.gserviceaccount.com
role: role/billing.admin
```

* Deploy the new IAM binding:

```
gcloud beta billing accounts set-iam-policy ${BILLING_ACCOUNT} billing.yaml
```

### Compute Shared VPC Admin

```
gcloud resource-manager folders add-iam-policy-binding $MA_FOLDER_ID --member=serviceAccount:tb-executor-0000@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.xpnAdmin
```

### Folder Admin

```
gcloud resource-manager folders add-iam-policy-binding $MA_FOLDER_ID --member=serviceAccount:tb-executor-0000@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.folderAdmin
```

### Project Creator

```
gcloud resource-manager folders add-iam-policy-binding $MA_FOLDER_ID --member=serviceAccount:tb-executor-0000@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.projectCreator
```

### Packer project image user

```
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:tb-executor-0000@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.imageUser
```

## Deploy Tranquility Base's bootstrap project

* Set credentials for terraform:
 
```
export GOOGLE_CREDENTIALS="$(pwd)/tb-executor-0000.json"
```
cd bootstrap/
```

* Edit your setup's specific variables on `input.tfvars`

```
vim input.tfvars
```

* Run terraform to deploy Tranquility Base's bootstrap.

```
terraform init
terraform apply -var-file=input.tfvars
```

**Note:** All resources are deployed under a GCP organisation folder and not under the organisation root node

**Note:** The default Tranquility Base deploys under a two tier folder hierarchy

### Note: There are some default username and passwords set when deploying Tranquility Base, these should be changed immediately after deployment
- itop: tb-gcp-tr
- vault: root token should be surfaced from the vault terraform module to the root terraform module and changed as soon as possible.
