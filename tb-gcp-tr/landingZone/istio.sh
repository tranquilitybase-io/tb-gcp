#!/bin/bash -xe


curl -L https://istio.io/downloadIstio | sh -

cd istio-1.5.4
export PATH=$PWD/bin:$PATH
cd ..


export HTTPS_PROXY="localhost:3128"

istioctl manifest apply
