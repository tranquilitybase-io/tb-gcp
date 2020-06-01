export HTTPS_PROXY="localhost:3128"
kubectl apply -f istio-pvt-ingressgateway-deployment.yaml
kubectl apply -f istio-pvt-ingressgateway.yaml
kubectl delete svc istio-ingressgateway --namespace=istio-system

## record ip with Cloud DNS
service_desc=($(kubectl describe services istio-private-ingressgateway --namespace=istio-system | grep 'LoadBalancer Ingress:'))
endpoint_ip=${service_desc[2]}
## todo gcloud command to add ip and domain to record set