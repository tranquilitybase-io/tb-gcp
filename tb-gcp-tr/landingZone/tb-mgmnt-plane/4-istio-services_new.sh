#!/bin/bash
export HTTPS_PROXY="localhost:3128"

istio_version=$(ls -1 /home/e_hsan/ | grep istio-1.9.4) 
export PATH=$PATH:/home/e_hsan/${istio_version}/bin/ 


istioctl manifest apply --set values.kiali.enabled=true \ --set values.grafana.enabled=true


kubectl apply -f /home/e_hsan/istio-kiali_new.yaml  -f /home/e_hsan/istio-grafana_new.yaml


