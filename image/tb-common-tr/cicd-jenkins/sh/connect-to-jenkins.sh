#!/usr/bin/env bash

gcloud container clusters get-credentials $CLUSTER --zone $ZONE --project $PROJECT
printf $(kubectl get secret cd-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo

export POD_NAME=$(kubectl get pods -l "component=$CLUSTER-master" -o jsonpath="{.items[0].metadata.name}")

kubectl port-forward $POD_NAME 8080:8080 >> /dev/null &