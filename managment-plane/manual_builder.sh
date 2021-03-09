# upload the yaml files to the cloud shell
# upload the config map


# create namespaces
env HTTPS_PROXY=localhost:3128 kubectl apply -f namespaces.yaml


# add gateways
env HTTPS_PROXY=localhost:3128 kubectl apply -f istio-pvt-ingressgateway.yaml
env HTTPS_PROXY=localhost:3128 kubectl apply -f istio-pvt-ingressgateway-deployment.yaml


# load SA.json into GKE
# configure a SA with the owner role, inline with whats in the code base here
## add to IAM
## grant
##"roles/resourcemanager.folderAdmin",
##"roles/resourcemanager.projectCreator",
##"roles/resourcemanager.projectDeleter",
##"roles/billing.projectManager",
##"roles/compute.xpnAdmin",
##"roles/owner",
##"roles/compute.networkAdmin",
# TODO: refine SA roles

# upload the json key to cloud shell
env HTTPS_PROXY=localhost:3128 kubectl create secret generic ec-service-account -n cicd --from-file=ec-service-account-config.json
env HTTPS_PROXY=localhost:3128 kubectl create secret generic ec-service-account -n ssp --from-file=ec-service-account-config.json


# set basic auth
env HTTPS_PROXY=localhost:3128 kubectl create secret generic dac-user-pass -n cicd --from-literal=username=dac --from-literal=password='bad_password' --type=kubernetes.io/basic-auth
env HTTPS_PROXY=localhost:3128 kubectl create secret generic dac-user-pass -n ssp --from-literal=username=dac --from-literal=password='bad_password' --type=kubernetes.io/basic-auth

# create config map
env HTTPS_PROXY=localhost:3128 kubectl apply -f configmap.yaml

# point to folder
env HTTPS_PROXY=localhost:3128 kubectl create secret generic gcr-folder -n cicd --from-literal=folder=940339059902

# deploy app
env HTTPS_PROXY=localhost:3128 kubectl apply -f storageclasses.yaml
env HTTPS_PROXY=localhost:3128 kubectl apply -f eagle_console.yaml
env HTTPS_PROXY=localhost:3128 kubectl apply -f jenkins-master.yaml



# Deployment is now completed
# to view the EC service:

# --------
# get the name of the eagle console pod
env HTTPS_PROXY=localhost:3128 kubectl get pods -n ssp

# use it in the next command
env HTTPS_PROXY=localhost:3128 kubectl get pod eagleconsole-v1-xxxxxxx -n ssp --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}'

# confirm port is 80, and forward to 8080
env HTTPS_PROXY=localhost:3128 kubectl port-forward eagleconsole-v1-54777654c8-ggmx5 -n ssp 8080:80

# --------
# IN A NEW SHELL TAB
# re establish HTTPS_PROXY
cd tb-gcp-management-plane-architecture
source ./scripts/config.sh
gcloud container clusters get-credentials tb-mgmt-gke --region $TG_REGION
env HTTPS_PROXY=localhost:3128 kubectl get nodes
env HTTPS_PROXY=localhost:3128 kubectl cluster-info

# inspect deployment
env HTTPS_PROXY=localhost:3128 kubectl get deployment -n ssp

# forward port to 80
env HTTPS_PROXY=localhost:3128 kubectl port-forward deployment/eagleconsole-v1 -n ssp :80

# in the shell window:
#   - click the preview in web button
#   - type in the port number from previous command e.g. 45741
# you should be navigated to the EC login page