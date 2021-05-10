#!/bin/bash
export HTTPS_PROXY="localhost:3128"

gcloud dns managed-zones create private-shared \
    --description=PrivateDNSzone \
    --dns-name=tranquilitybase-demo.io. \
    --networks=tb-mgmt-network \
    --visibility=private

## record ip with Cloud DNS
service_desc=($(kubectl describe services istio-private-ingressgateway --namespace=istio-system | grep 'LoadBalancer Ingress:'))

endpoint_ip=${service_desc[2]}


unset HTTPS_PROXY
PROJECT_ID=$(gcloud config list --format 'value(core.project)' 2>/dev/null)

gcloud dns --project="${PROJECT_ID}" record-sets transaction start --zone=private-shared
gcloud beta dns --project="${PROJECT_ID}" record-sets transaction add "${endpoint_ip}" --name=eagle-console.tranquilitybase-demo.io --ttl=300 --type=A --zone=private-shared
gcloud beta dns --project="${PROJECT_ID}" record-sets transaction execute --zone=private-shared
