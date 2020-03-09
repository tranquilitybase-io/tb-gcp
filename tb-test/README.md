# Setting up Cloud Build for Tranquility Base

* Create project 'tbase-ci'

* Enable following APIs for tbase-ci
    * Cloud Build API
    * Compute Engine API
    * Cloud Resource Manager API

* Enable following permissions for tbase-ci cloud build service account (will be called something like 196121977599@cloudbuild.gserviceaccount.com)
    * Compute Engine (From Cloud Build Settings)
    * Service Accounts (From Cloud Build Settings)
    * Security Reviewer (from IAM & admin)

* Add same permissions and policies for this service account as are added for the tb-bootstrap-builder service account in the root [README.md](../README.md) file

* Create Packer, Terraform and Inspec images in Container Registry for this project
    * Checkout [Cloud Builders Community project](https://github.com/GoogleCloudPlatform/cloud-builders-community) from Github
        * `git clone https://github.com/GoogleCloudPlatform/cloud-builders-community.git`    

    * Create a Packer builder image in Container Registry - see [here](https://cloud.google.com/cloud-build/docs/quickstart-packer)
        * `cd cloud-builders-community/packer`
        * `gcloud builds submit .`

    * Create a Terraform builder image in Container Registry  
        * `cd cloud-builders-community/terraform`
        * `gcloud builds submit .`

    * Create a Inspec builder image in Container Registry  
        * `cd cloud-builders-community/inspec`
        * `gcloud builds submit .`

* From [here](https://console.cloud.google.com/cloud-build/triggers)
    * **Connect repository** and mirror Tranquility Base Github repo with Google repo within project (needs Github authentication)
    * **Create trigger** for the repo branch to be tested and pointed at the cloudbuild.yaml file        

## Cloud Build Links
* [Overview](https://cloud.google.com/cloud-build/docs/overview)

* [Build Configuration (YAML or JSON)](https://cloud.google.com/cloud-build/docs/build-config)
    * Series of steps, each one using a Docker container image that can performs a particular task e.g. ubuntu, npm, docker, kubectl

* [Built-in official images](https://github.com/GoogleCloudPlatform/cloud-builders) including docker, git, javac, mvn, gcloud, kubectl in this [Github](https://github.com/GoogleCloudPlatform/cloud-builders)

* [Google Cloud Builders Community](https://github.com/GoogleCloudPlatform/cloud-builders-community) for many other images such as ansible, packer, terraform, vault etc

* [cloud-build-local](https://cloud.google.com/cloud-build/docs/build-debug-locally)
    * Use cloud-build-local to test scripts from laptop without checking in. 
    * NB this ONLY works on mac and linux NOT windows. Requires docker
    * `cloud-build-local --config=[BUILD_CONFIG] --dryrun=false --push [SOURCE_CODE]`
