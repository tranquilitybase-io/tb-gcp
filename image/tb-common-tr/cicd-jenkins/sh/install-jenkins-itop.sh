#!/usr/bin/env bash

#set environment variables
source ./environment.sh

#helm
wget -P ./helm/ https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz
tar xf ./helm/helm-v2.11.0-linux-amd64.tar.gz  -C $PWD

export PATH="$PATH:$PWD/linux-amd64/"

#connect to cluster
gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT

#Give cluster-admin access to current user
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin \
        --user=$(gcloud config get-value account)

# create tiller account
kubectl create serviceaccount tiller --namespace kube-system
kubectl create clusterrolebinding tiller-admin-binding --clusterrole=cluster-admin \
           --serviceaccount=kube-system:tiller

# init helm
helm init --service-account=tiller
helm update
sleep 60

#install Jenkins
helm install -n cd stable/jenkins -f ../k8s/jenkins/values.yaml --version 0.16.6 --wait

# install itop
kubectl apply -f ../k8s/itop/itop-deployment.yaml

#Shut down
#sudo poweroff