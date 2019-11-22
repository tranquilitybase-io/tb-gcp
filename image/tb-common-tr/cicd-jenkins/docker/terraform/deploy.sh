#!/usr/bin/env bash
docker-compose -f docker-compose-jenkins.yaml build
docker-compose -f docker-compose-jenkins.yaml run gcp-sdk bash -c 'eval `ssh-agent -s`; ssh-add; cd /mnt/jenkins-deployment; gcloud auth login; exec bash;'
docker-compose -f docker-compose-jenkins.yaml down