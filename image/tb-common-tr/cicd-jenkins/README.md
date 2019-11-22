# JenkinsGKE

A Google Cloud Platform project to provision a Kubernetes cluster on Google Kubernetes Engine and make use of a
Google Compute Engine instance to install Jenkins and iTop onto the cluster.
 
This repository is was designed to meet the requirements for the GFT Microservices Activator PoC.
 
# What's in this repository?

* Docker Images `/docker`
    * Terraform `/docker/terraform/` (terraform, gcloud)
    * Jenkins Pipeline `/docker/jenkins/` (kubectl, istio, helm)
* Kubernetes Deployments `/k8s`
    * iTop with Load Balancer `/k8s/itop/itop-deployment.yaml`
    * Jenkins `/k8s/jenkins/values.yaml`
* Terraform plans `/`
    * Resources `/main.tf` (GKE Cluster, GKE Node Pool, GCE Instance)
    * Variables `/variables.tf` 
* Installation Scripts `/sh/`
    * Variables `/sh/environment.sh`
    * Jenkins & iTop Installation script `/sh/install-jenkins-itop.sh`
* Other
    * Bastion Host Clean up `/sh/delete-bastion-host.sh`

# Pre-requisites

* Google Cloud Platform Project
* A Google account associated to the Project with permissions:
    * Kubernetes Admin
    * Google Compute Engine Admin
    * Ability to generate Service Account keys
* Terraform installed locally
* Cloud shell or terminal with `gcloud` SDK installed.
* Access to Cloud Repositories (Optional)
* Git 

# Environment Properties
Customise as appropriate before deployment.

## Terraform
Properties can be found in the `/variables.tf` file. 

* The Project name
* Regions and Zones
* Username/Password (why is this in here?)
* Resource names
* Machine types

## Bastion Host - Kubernetes
The bastion host installed jenkins by pulling this repository and executing scripts in the `/sh/` directory.

The following variables to define which cluster to install jenkins to can be found in the `/sh/environment.sh` script.

* GCP Project
* Compute Zone
* Kubernetes Cluster name

The service account `cd-jenkins@gft-microservices-activator.iam.gserviceaccount.com` is used to deploy to the cluster.

Note: Check there are no name conflicts with existing resources.

## Security and Authentication
A Service Account is required for both Terraform and Jenkins to run successfully.

The account JSON key should be stored in `/creds/key.json`.

You can use and customise the `/creds/generate-key.sh` script to generate a new key file in the above location.

The default account used is `cd-jenkins@gft-microservices-activator.iam.gserviceaccount.com`

# Terraform the GCP resources
From a terminal in the repository's root directory execute
 
 `terraform plan`
 
This will output a terraform plan of the GCP resources to be provisioned. Details are in the `main.tf` file.
 
The plan should generate with actions to provision 3 resources:
1. Google Compute Instance
2. Google Container Cluster (GKE Cluster)
3. Google Container Node Pool (GKE Node Pool)
  
When satisfied apply the Terraform plan and confirm using
  
`terraform apply`
  
## Jenkins

### Connecting to Jenkins UI
Apply updates, configure the system and create pipelines through the Jenkins UI. 

You can execute `/sh/connect-to-jenkins.sh` from your cloud shell or run the following commands manually

1. Open cloud shell
2. Connect to the cluster:
  * `gcloud container clusters get-credentials cd-jenkins --zone europe-west2-b --project gft-microservices-activator`
 
3. Receive the `admin` password for the Jenkins UI

  * `printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo`

4. Setup port forwarding to port 8080
    1. `export POD_NAME=$(kubectl get pods -l "component=cd-jenkins-master" -o jsonpath="{.items[0].metadata.name}")`
    2. `kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &` 
    
5. Click web preview from cloud shell > preview on port 8080

### Jenkins Configuration
The following items will all need to be configured once Jenkins has been installed.

1. Fix dependencies and Update Plugins
    * navigate to `Manage Jenkins` in the UI and "Correct" the dependency errors.
2. Generate Credentials
    * Google Cloud Service Account From Private Key
        * Must have Kubernetes Admin and Cloud Repository Access
        * Check the Security and Authentication section on how to generate a new key
    * Kubernetes Secret
3. Configure System
    * Jenkins URL `http://cd-jenkins.default.svc.cluster.local:8080`
    * Jenkins Tunnel `cd-jenkins-agent.default.svc.cluster.local:50000`
    * Kubernetes pod Template
    * Container Template
      * Name: `k8s-istio-helm`
      * Docker Image: `eu.gcr.io/gft-microservices-activator/k8s-helm-istio-deploy`
    * Cloud Credentials (Kubernetes secret generated previously - `secret text`)
3. Create Multibranch Pipeline
    * Use Cloud Repository as source
    * Use credentials created during configuration

Note: 
* The Jenkins URL and Tunnel use the format `my-svc.my-namespace.svc.cluster.local:port`. 
* Credentials for your pipeline must have access to this repository.

## Microservices Activator Pipeline

This project was designed as part of the CI/CD process for deploying the GFT Microservices Activator applications. 
The `Jenkinsfile` can be found in the Cloud Repository

* https://source.developers.google.com/p/gft-microservices-activator/r/IstioActivator
* gcloud source repos clone IstioActivator --project=gft-microservices-activator

You will need to manually create the Pipeline through the Jenkins UI. 
Use the credentials previously created to connect to the Cloud Repository

### Docker
A docker image pre-built with kubectl, istio and helm can be found int `/docker/jenkins/` and is hosted in the GCP Container Registry.
This image is used by Jenkins to deploy the Istio Activator application on the it's cluster.

[k8s-helm-istio Docker Image Host](eu.gcr.io/gft-microservices-activator/k8s-helm-istio-deploy)

## iTop
Has an external load balancer on Port 80.
  
# Configuration files

* Jenkins `k8s/jenkins/`
* iTop `k8s/itop/`
 
# Billing
Deploying this cluster onto your Project will incur Billing costs from the platform. 
 
# Improvements
The GCE instance remains online after deployment. We should fix this. In the mean time please delete or disable manually

# Tools
* Terraform
* Jenkins
* Docker
* Kubernetes
* iTop

# Useful Links

## Google Kubernetes Engine
* https://cloud.google.com/solutions/jenkins-on-kubernetes-engine-tutorial
* https://cloud.google.com/solutions/jenkins-on-kubernetes-engine
* https://cloud.google.com/solutions/continuous-delivery-jenkins-kubernetes-engine
* https://cloud.google.com/solutions/configuring-jenkins-kubernetes-engine
* https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/

## Terraform
* https://www.terraform.io/docs/providers/google/r/container_cluster.html
* https://www.terraform.io/docs/providers/google/r/container_node_pool.html
* https://cloud.google.com/iam/docs/creating-managing-service-account-keys#iam-service-account-keys-create-gcloud

## iTop 
* https://www.itophub.io/

## Jenkins
* https://jenkins.io/

## Container Registry / Docker
* https://cloud.google.com/container-registry/docs/quickstart
* https://cloud.google.com/container-registry/docs/pushing-and-pulling

# Contact
* mathew.stacey@gft.com
* emily.forst@gft.com