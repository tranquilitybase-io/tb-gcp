#Use Kubectl base image
FROM gcr.io/cloud-builders/kubectl
#Update
RUN apt-get update && \
    apt-get install wget -y
#Install Istio
RUN wget https://github.com/istio/istio/releases/download/1.0.3/istio-1.0.3-linux.tar.gz && \
    tar xzf istio-1.0.3-linux.tar.gz
#Install Helm
RUN wget https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz && \
    tar xf helm-v2.11.0-linux-amd64.tar.gz
#Add Helm and Istio to Path
ENV PATH=/istio-1.0.3/bin/:/helm-v2.11.0/linux-amd64/:$PATH