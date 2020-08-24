#!/bin/bash

ISTIO_VERSION=1.6.8

sp='/-\|'
sc=0
spin() {
    printf "\b${sp:sc++:1}"
    ((sc==${#sp})) && sc=0
    sleep 0.1
}


endspin() {
    printf '\r%s\n' "$*"
    sleep 0.1
}


# Check that kubectl is installed

printf "Checking kubectl is installed...\n"

if ! [ -x "$(command -v kubectl)" ]; then
  case "$OSTYPE" in
  darwin*)  curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl; chmod +x kubectl ; mv kubectl /usr/local/bin/;;
  linux*)   curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl; chmod +x kubectl ; mv kubectl /usr/local/bin/ ;;
  *)        echo "Unknown OS: $OSTYPE" ;;
esac


fi


printf "Checking curl is installed...\n"

if ! [ -x "$(command -v curl)" ]; then
  case "$OSTYPE" in
  darwin*)  brew install curl ;;
  linux*)   sudo apt install curl ;;
  *)        echo "Unknown OS: $OSTYPE" ;;
esac


fi

printf "Downloading and installing Istio...\n"
# Download Istio binaries
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} TARGET_ARCH=x86_64 sh - > /dev/null 2>&1
version=$(ls -1d istio-1*)
export PATH="$PATH:$PWD/$version/bin"

export HTTPS_PROXY="localhost:3128"

#Initalise istio
istioctl operator init > /dev/null 2>&1

sleep 30
kubectl create ns istio-system
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  namespace: istio-system
  name: example-istiocontrolplane
spec:
  profile: demo
EOF



count=0
printf "Waiting for services to come online...\n"
while true; do
    count=$(kubectl get pods -n istio-system |grep -i running |wc -l)
    spin
    sleep 1
    if [[ $count -ne 7 ]]; then
      sleep 0.2
    else
      break
    fi
done
endspin
printf "Service are online...\n"



kubectl get pods -n istio-system


printf "Enabling Istio Injection...\n"
kubectl label namespace default istio-injection=enabled > /dev/null 2>&1
kubectl describe namespace default |grep -i labels
