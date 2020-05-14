# Tranquility Base 

Hi, and welcome to Tranquility Base - the open source multi-cloud infrastructure-as-code Landing Zone together with a self-service portal for automating the provisioning of a set of DevOps-ready reference architectures. For further description of Tranquility Base, please head over to [tranquilitybase.io](https://www.tranquilitybase.io/).

The current version is feature complete for this release but we are aware there will be bugs to be fixed and patches to be made. For example there will be security improvements to be made and we are working to identify and update the codebase to address them. Please review the issues list for an idea of the enhancements and fixes we're planning to implement. If you want to help us with this or contribute to Tranquility Base in general please contact us on [contact@tranquilitybase.io]

**There are 2 ways to deploy Tranquility base:**
1. Deploy using Market Place
2. Manual process


## Deploying using Google Marketplace:
Follow the instructions in the README.md file of the `tb-marketplace` directory.

## Manual Deployment instructions

The following instructions assume the following requisites are met:
* a project exists to host a service account and GCE images which will be used to deploy Tranquility Base;
* an organization exists as well as a folder under it. Tranquility Base's folder structure and projects will be created under this organization or folder;
* a billing account has been previously setup and can be used for all projects created by Tranquility Base;
* `terraform` `~0.12` is installed;
* `packer` `~1.4` is installed.


### Initial setup:

* Setup environment variables to help through the deployment process:

``` bash
BILLING_ACCOUNT=<billing_account_id>
PARENT_FOLDER_ID=<parent_folder_id>
PROJECT_ID=<project_id>
```

### Create Tranquility Base Folder
* Create a folder to contain the tranquility base deployment:

``` bash
gcloud resource-manager folders create --display-name="${TBASE_FOLDER_NAME}" --folder="${PARENT_FOLDER_ID}"
```

* Get the folder ID and set as another environment variable:
```bash
FOLDER_ID=<folder_id>
```

### Service Account Creation

* Create a service account which will be used during the initial deployment process:

``` bash
gcloud --project ${PROJECT_ID} iam service-accounts create tb-bootstrap-builder
gcloud --project ${PROJECT_ID} iam service-accounts keys create tb-bootstrap-builder.json --iam-account tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com
```

### Grant permissions to manage billling

* Give the new service account the ability to link projects to the billing account.

``` bash
gcloud beta billing accounts get-iam-policy ${BILLING_ACCOUNT} > billing.yaml
```
 
* Edit `billing.yaml` and add the following entry to the existing bindings (replace `PROJECT_ID` below before saving):

``` yaml
members:
- serviceAccount:tb-bootstrap-builder@PROJECT_ID.iam.gserviceaccount.com
role: roles/billing.admin
```

* Deploy the new IAM binding:

``` bash
gcloud beta billing accounts set-iam-policy ${BILLING_ACCOUNT} billing.yaml
```

### Grant permissions to Share VPCs

* Give the service account the ability to share VPCs among projects:

```
gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.xpnAdmin
```

### Grant permissions to manage the folder

* Give the service account the ability to create new folders and manage their IAM policies:

``` bash
gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.folderAdmin
```

### Grant permissions to create new projects

* Give the service account the ability to create new project under the new folder structure:

``` bash
gcloud resource-manager folders add-iam-policy-binding ${FOLDER_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/resourcemanager.projectCreator
```

### Grant permissions to create GCE instances and images

* Give the service account the ability to create and use GCE disk images:

``` bash
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.instanceAdmin.v1
```

### Activate essential APIs

```
gcloud --project ${PROJECT_ID} services enable compute.googleapis.com
gcloud --project ${PROJECT_ID} services enable cloudresourcemanager.googleapis.com
gcloud --project ${PROJECT_ID} services enable cloudbilling.googleapis.com
gcloud --project ${PROJECT_ID} services enable iam.googleapis.com
gcloud --project ${PROJECT_ID} services enable serviceusage.googleapis.com
gcloud --project ${PROJECT_ID} services enable storage-api.googleapis.com
```

### Start using the service account:

* Authenticate `gcloud` with the new service account:

``` bash
gcloud auth activate-service-account tb-bootstrap-builder@${PROJECT_ID}.iam.gserviceaccount.com --key-file=tb-bootstrap-builder.json
```

* Setup the environment for Terraform:
 
``` bash
export GOOGLE_CREDENTIALS="$(pwd)/tb-bootstrap-builder.json"
```

### Build Tranquility Base terraform-server GCE image

* Clone the repository:

``` bash
git clone git@github.com:tranquilitybase-io/tb-gcp.git
cd tb-gcp
```

**NOTE:** If the cloning operation fails, make sure you have an SSH key added to your GitHub profile or just use the `https` URL [https://github.com/tranquilitybase-io/tb-gcp.git] instead.

* Use packer to create a GCE for the terraform-server:

  **Note: Use `packer-no-itop.json` instead of `packer.json` in order to disable iTop.**

``` bash
cd tb-gcp-deploy/pack/
packer build -var "project_id=${PROJECT_ID}" packer.json
cd ../../
```


### Deploy Tranquility Base's bootstrap project

``` bash
cd tb-gcp-tr/bootstrap/
```

* Edit your setup's specific variables on `input.tfvars`. There's a `enable_itop` variable, set it to `false` to disable iTop and `true` to enable it.
 
``` bash
vim input.tfvars
```

* Run terraform to deploy Tranquility Base's bootstrap.

``` bash
terraform init
terraform apply -var-file=input.tfvars
```

**Note:** Tranquility Base's bootstrap deployment (phase 1) is followed automatically by a landingZone deployment (phase 2) which is run from the `terraform-server` hosted under a `bootstrap-` project under the folder ID stated on the `input.tfvars`.

### Follow the landingZone deployment

* The landingZone deployment's progress can be followed by inspecting the `terraform-server`'s Stackdriver logs.

**Note:** All resources are deployed under the folder ID stated on the `input.tfvars` file.

**Note:** Tranquility Base deploys under a two tier folder hierarchy under the folder ID stated stated on the `input.tfvars` file.


### Wrap-up tasks

1. After the bootstrap deployment, you may want to disable the `tb-bootstrap-builder` service account;
1. An initial password for the `itop` user used to access the Cloud SQL instance on the `shared-itsm-` project, this password is displayed on the `terraform-server` logs and should be reset as soon as possible;
1. vault: root token should be surfaced from the vault terraform module to the root terraform module and changed as soon as possible.

### Inspec tests

Attributes can be defined in tb-test/attributes.yml

The actual tests are defined in tb-test/controls/example.rb


1. Download [inspec](https://downloads.chef.io/inspec)
2. Create a service account with permissions to view the resources you wish to test, and set an environment variable to point to the location of the service account key
``` 
export GOOGLE_APPLICATION_CREDENTIALS='/Users/me/Downloads/myservice-account-key.json'
```
3. Run the tests
```
cd tb-test
inspec exec . -t gcp:// --input-file=attributes.yml
```
Inspec is [documented](https://github.com/inspec/inspec-gcp) quite well 
