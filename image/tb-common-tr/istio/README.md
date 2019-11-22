TB Istio Terraform module
=========================

Installs **Istio** on an existing Kubernetes cluster using Istio [Helm](https://helm.sh/) charts. 

[![Istio.io](https://istio.io/favicons/android-192x192.png)](https://istio.io)

Currently, it supports the following Kubernetes varieties:
- **GKE** - Kubernetes on Google Cloud Platform
- **EKS** - Kubernetes on AWS Cloud Platform

Please visit [istio.io](https://istio.io) for in-depth information about using **Istio**.

The module assumes that you have already created a cluster and it is configured as default.


Prerequisites
-------------

All Istio components will be installed in a separated `istio-system` namespace within an existing Kubernetes cluster pointed out by the _current context_ of standard Kubernetes configuration defined in file given in `kubernetes_config_path`.

Installation
------------

* `terraform init`
* `terraform plan`
* `terraform apply`

Inputs:
------------

**istio_version**  
Istio version in form X.Y.Z (default value: '1.1.6'). It is used to select proper Istio Helm chart from https://storage.googleapis.com/istio-release/releases/X.Y.Z/charts/  
  
**kubernetes_config_path**  
String with path to configuration file for kubernetes cluster the istio will be attached to. The default value is '~/.kube/config'
