export HTTPS_PROXY="localhost:3128"
kubectl apply -f istio-pvt-ingressgateway-deployment.yaml
kubectl apply -f istio-pvt-ingressgateway.yaml
