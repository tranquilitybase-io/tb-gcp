# Pull base image.
FROM ubuntu:latest

RUN \
# Update
apt-get update -y && \
# Install Unzip
apt-get install unzip -y && \
# need wget
apt-get install wget -y && \
# curl
apt-get install curl -y

################################
# Install Python
################################

RUN apt-get install -y python3-pip
#RUN ln -s /usr/bin/python3 python
RUN pip3 install --upgrade pip
RUN pip3 install google-cloud-resource-manager
RUN python3 -V
RUN pip --version

################################
# Install Gcloud
################################

RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin