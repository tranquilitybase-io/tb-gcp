# Copyright 2019 The Tranquility Base Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Collect TB source code from the external repository
# ---------------------------------------------------
FROM alpine/git AS tbcode

RUN mkdir -p /opt/tb/repo
WORKDIR /opt/tb/repo

COPY tb-common-tr /opt/tb/repo/tb-common-tr/
COPY tb-gcp-tr /opt/tb/repo/tb-gcp-tr/
COPY tb-gcp-activator /opt/tb/repo/tb-gcp-activator/

RUN rm -rf **/.git  rm -rf **/.gitignore **/.idea
# RUN rm -R tb-gcp

# Build EC derivelable image
# --------------------------
FROM python:3.7

RUN mkdir -p /opt/tb/repo
COPY --from=tbcode /opt/tb/repo /opt/tb/repo/

RUN mkdir -p /opt/ec \
    && mkdir -p /opt/ec/bash \
    && mkdir -p /root/.ssh

COPY tb-ec-gcp/main.py /opt/ec/
COPY tb-ec-gcp/requirements.txt /opt/ec/
COPY tb-ec-gcp/modules /opt/ec/modules/
RUN ls -l /opt/ec

# START install gcloud
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin
RUN gcloud components install beta kubectl --quiet
# END install gcloud

RUN pip install -r /opt/ec/requirements.txt

RUN  apt-get update -y && \
     apt-get upgrade -y && \	
     apt-get dist-upgrade -y && \
     apt-get -y autoremove && \
     apt-get clean

RUN apt-get install -y p7zip \
    zip \
    unzip

RUN apt-get install -y git
RUN apt-get install -y dos2unix

COPY tb-ec-gcp/git_bash_scripts /opt/ec/bash/
COPY tb-ec-gcp/tf_create_subnets /opt/ec/tf_create_subnets/

RUN chmod +x /opt/ec/bash/commit_changes.sh && \
    chmod +x /opt/ec/bash/git_init.sh && \
    chmod +x /opt/ec/bash/pull_changes.sh

RUN dos2unix /opt/ec/bash/commit_changes.sh && \
    dos2unix /opt/ec/bash/git_init.sh && \
    dos2unix /opt/ec/bash/pull_changes.sh

ADD https://releases.hashicorp.com/terraform/0.12.17/terraform_0.12.17_linux_amd64.zip bin/
RUN unzip -d bin/ bin/terraform_0.12.17_linux_amd64.zip
ENV PATH=$PATH:/

# Enable Terraform logging
ENV TF_LOG=ERROR
ENV TF_LOG_PATH=/var/log/tb-ec-gcp-deployment.log

EXPOSE 5000

ARG service_version
ENV SERVICE_VERSION ${service_version:-v1}

WORKDIR /opt/ec
CMD python -u main.py
