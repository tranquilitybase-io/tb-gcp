#!/bin/bash
export HTTPS_PROXY="localhost:3128"
kubectl apply -f /opt/tb/repo/tb-gcp-tr/landingZone/istio-pvt-ingressgateway-deployment.yaml
kubectl apply -f /opt/tb/repo/tb-gcp-tr/landingZone/istio-pvt-ingressgateway.yaml
kubectl delete svc istio-ingressgateway --namespace=istio-system

## record ip with Cloud DNS
service_desc=($(kubectl describe services istio-private-ingressgateway --namespace=istio-system | grep 'LoadBalancer Ingress:'))
endpoint_ip=${service_desc[2]}

unset HTTPS_PROXY
PROJECT_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
TB_DISCRIMINATOR="${PROJECT_ID: -8}"
SHARED_NETWORKING_PROJECT=shared-networking-${TB_DISCRIMINATOR}
gcloud dns --project="${SHARED_NETWORKING_PROJECT}" record-sets transaction start --zone=private-shared
gcloud beta dns --project="${SHARED_NETWORKING_PROJECT}" record-sets transaction add "${endpoint_ip}" --name=eagle-console.private.landing-zone.com. --ttl=300 --type=A --zone=private-shared
gcloud beta dns --project="${SHARED_NETWORKING_PROJECT}" record-sets transaction execute --zone=private-shared

## create certificates and keys
#sudo mkdir /tmp/certs
#sudo openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=TB Inc./CN=private.landing-zone.com' -keyout /tmp/certs/private.landing-zone.com.key -out /tmp/certs/private.landing-zone.com.crt
#sudo openssl req -out /tmp/certs/eagle-console.private.landing-zone.com.csr -newkey rsa:2048 -nodes -keyout /tmp/certs/eagle-console.private.landing-zone.com.key -subj "/CN=eagle-console.private.landing-zone.com/O=eagle-console organization"
#sudo openssl x509 -req -days 365 -CA /tmp/certs/private.landing-zone.com.crt -CAkey /tmp/certs/private.landing-zone.com.key -set_serial 0 -in /tmp/certs/eagle-console.private.landing-zone.com.csr -out /tmp/certs/eagle-console.private.landing-zone.com.crt

## create secret
kubectl create -n istio-system secret tls ec-tls-credential --key=/opt/certs/eagle-console.private.landing-zone.com.key --cert=/opt/certs/eagle-console.private.landing-zone.com.crt
