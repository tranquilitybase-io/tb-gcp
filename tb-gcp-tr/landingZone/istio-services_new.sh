#!/bin/bash -x
export HTTPS_PROXY="localhost:3128"

istio_version=$(ls -1 /opt/tb/repo/tb-gcp-tr/landingZone/no-itop/ | grep istio)
export PATH=$PATH:/opt/tb/repo/tb-gcp-tr/landingZone/no-itop/${istio_version}/bin/



istioctl manifest apply --set values.kiali.enabled=true

/usr/bin/kubectl apply -f /opt/tb/repo/tb-gcp-tr/landingZone/istio-kiali_new.yaml






