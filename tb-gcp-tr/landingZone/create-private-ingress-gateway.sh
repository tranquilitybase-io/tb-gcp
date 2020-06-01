export HTTPS_PROXY="localhost:3128"
kubectl apply -f istio-pvt-ingressgateway-deployment.yaml
kubectl apply -f istio-pvt-ingressgateway.yaml
kubectl delete svc istio-ingressgateway --namespace=istio-system

## record ip with Cloud DNS
service_desc=($(kubectl describe services istio-private-ingressgateway --namespace=istio-system | grep 'LoadBalancer Ingress:'))
endpoint_ip=${service_desc[2]}

unset HTTPS_PROXY

PROJECT_ID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
TB_DISCRIMINATOR="${PROJECT_ID: -8}"
SHARED_NETWORKING_PROJECT=shared-networking-${TB_DISCRIMINATOR}
gcloud dns --project=${SHARED_NETWORKING_PROJECT} record-sets transaction start --zone=private-shared
gcloud beta dns --project=${SHARED_NETWORKING_PROJECT} record-sets transaction add ${endpoint_ip} --name=eagle-console.private.landing-zone.com. --ttl=300 --type=A --zone=private-shared
gcloud beta dns --project=${SHARED_NETWORKING_PROJECT} record-sets transaction execute --zone=private-shared