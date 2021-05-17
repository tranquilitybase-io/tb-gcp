#!/bin/bash
export HTTPS_PROXY="localhost:3128"

istio_version=$(ls -1 /home/e_hsan/ | grep istio-1.9.4) 
export PATH=$PATH:/home/e_hsan/${istio_version}/bin/ 


kubectl apply -f  /home/e_hsan/kiali.yaml -f /home/e_hsan/grafana.yaml 

kubectl apply -f /home/e_hsan/istio-kiali.yaml  -f /home/e_hsan/istio-grafana.yaml 