#!/usr/bin/env bash

gcloud auth configure-docker
docker build -t k8s-helm-istio-deploy .
docker tag k8s-helm-istio-deploy eu.gcr.io/gft-microservices-activator/k8s-helm-istio-deploy
docker push eu.gcr.io/gft-microservices-activator/k8s-helm-istio-deploy
