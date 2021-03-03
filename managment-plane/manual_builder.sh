# create namespaces
env HTTPS_PROXY=localhost:3128 kubectl apply -f namespaces.yaml


# load SA.json into GKE
env HTTPS_PROXY=localhost:3128 kubectl create secret generic ec-service-account -n cicd --from-file=ec-service-account-config.json
env HTTPS_PROXY=localhost:3128 kubectl create secret generic ec-service-account -n ssp --from-file=ec-service-account-config.json

# set basic auth
env HTTPS_PROXY=localhost:3128 kubectl create secret generic dac-user-pass -n ssp --from-literal=username=dac --from-literal=password='bad_password' --type=kubernetes.io/basic-auth

# create config map
env HTTPS_PROXY=localhost:3128 kubectl apply -f configmap.yaml

# point to folder
env HTTPS_PROXY=localhost:3128 kubectl create secret generic gcr-folder -n cicd --from-literal=folder=940339059902

# deploy app
env HTTPS_PROXY=localhost:3128 kubectl apply -f storageclasses.yaml
env HTTPS_PROXY=localhost:3128 kubectl apply -f eagle_console.yaml
env HTTPS_PROXY=localhost:3128 kubectl apply -f jenkins-master.yaml