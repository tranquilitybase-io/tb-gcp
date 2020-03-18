# Itop on GKE

This module allows iTop to be installed on a GKE cluster.
This uses Helm charts to deploy the iTop.
This module will install Helm and Tiller into the GKE Cluster.


## Prerequisites
Terraform roles required to run this:
* Project Editor
* Project IAM Admin (1)

Required enabled APIs for the project:
* Google Cloud SQL Admin API (sqladmin.googleapis.com)
* Google Container Registry API (containerregistry.googleapis.com)
* Google Kubernetes Engine API (container.googleapis.com)
* Google Service API (serviceusage.googleapis.com)
* Google IAM API (iam.googleapis.com)
* Compute Engine API (compute.googleapis.com)

Tools:
* Kubectl

Resources required:
* `GKE Cluster with istio` enabled because this will be using the istio ingress gateway to expose the iTop APIs.


## Terraform and Google Provider versions

`Terraform ~> 0.12` and `Google Provider ~> 2.16`

## Usage

### Step 1: Setup ###

Authenticate to GCP using the gcloud init command, providing the email address for the GCP user.

Note: if you wish to run the terraform as a service account then
* Download the service account json key to somewhere local
* run the command
```sh
export GOOGLE_CLOUD_KEYFILE_JSON=<fully qualified path of your json key file>
#e.g.
export GOOGLE_CLOUD_KEYFILE_JSON=/mnt/c/Users/chung/terraform-svc-acc-01-42ef05f1bbbc.json
```
* Optional:- If you not hava a GCK Cluster running, create one using the command below:
```sh
gcloud beta container clusters create gke-istio \
 --addons=Istio --istio-config=auth=MTLS_PERMISSIVE \
 --machine-type=n1-standard-1 \
 --num-nodes=1
```
* Set the kubectl context to the new cluster
```sh
# set the kubectl context to the new cluster
gcloud container clusters get-credentials [cluster-name] --project=[project-id]
#e.g.
gcloud container clusters get-credentials gke-istio --project=[project-id]
```

### Step 2: Running Simple Example ###

1. cd into examples/simple/

2. IMPORTANT: Make a copy of the `terraform_examples.tfvars` with the name `terraform.tfvars`. Amend the terraform.tfvars file accordingly

3. Run the following commands:

```sh
 terraform init

 terraform validate

 terraform plan

 terraform apply

 # check the app is running by running these example commands
kubectl get services -n itop
kubectl get pods -n itop -o wide
kubectl get virtualservices -n itop
kubectl get gateways -n itop

# get tthe load balancer IP address to access the itop application
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# run the command below and copy the url into the browser
echo http://$INGRESS_HOST
    # e.g. example output
    http://130.211.126.156/
```

### Step 3: Configure the Itop application for first time use ###

When you load the application the first time it will take you to the setup screen:
enter the following to setup the database:
* Choose install new database
* Server name: 127.0.0.1
* Login: itop (default)
* password: randomly generated during bootstrap and output to logs.

Then follow the screen to continue the setup.

## Inputs


## Outputs



### Troubleshooting ###

#### Check the error logs first ####
* Read the itop pod events for any error
```sh
# Get the pod names in the cluster
kubectl get pods -n [your itop namespace]
# e.g.
kubectl get pods -n itop

# Read the events at the end to get the reason for failure
# This also shows the containers in the Pod
kubectl describe pod [your itop pod]  -n [your itop namespace]
# e.g.
kubectl describe pod itop-7447b554fd-qp428  -n itop

# get a pod container full log
kubectl logs -f [your itop pod] -c [container in the pod] -n [your itop namespace]
#e.g.
kubectl logs -f itop-7447b554fd-qp428 -c istio-proxy -n itop
kubectl logs -f itop-7447b554fd-qp428 -c cloudsql-proxy -n itop
kubectl logs -f itop-7447b554fd-qp428 -c itop -n itop
```

#### Unable to Create a new iTop database from the UI ####
This could be istio is preventing the cloudsql side proxy from connecting to the Cloudsql Mysql database.
Ensure the serviceEntry is allowing egress traffic to www.googleapis.com and the Cloudsql ip address on GCP.

#### Unable to access the application via the LoadBalancer ####
Try connecting directly to the itop pod using port forwarding to see if the application is running
```sh
# Try using kubectl port forward kubectl to connect directly
kubectl port-forward -n itop $(kubectl get pod -n itop -l app=itop -o jsonpath='{.items[0].metadata.name}') 8888:80
# the try connecting http://localhost:8888 to the browser.
```

#### Unbale to apply the helm via terraform ####
Check the Tiller Deploy log for further investigation
```sh
# example
kubectl logs -f tiller-deploy-779784fbd6-t8qdw -n kube-system
```

#### Not able to connect to Cloud SQL instance
Check itop pod's cloudsqlproxy container logs as shown above on this troubleshooting section.

#### Useful commands ####
```sh
# connecting to a pod container for further investigation
kubectl exec [your itop pod] -c [container in the pod] -- [/bin/bash or /bin/sh] -it -n [your itop namespace]
# e.g. (you must have -- /bin/bash last)
kubectl exec itop-7447b554fd-qp428 -c itop -n itop -it -- /bin/bash
```

## Future works ##
* Add SSL/TLS to istio load balancers
* Configure the Itop Pod to Use a PersistentVolume for Storage.
