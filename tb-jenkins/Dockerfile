FROM jenkins/jenkins:lts

# this is just a tempoary hack until we get the slaves up and running
COPY terraform /usr/local/bin/terraform 

USER root

RUN apt-get update
RUN apt-get install -y python-pip 

RUN  pip install awscli --upgrade --user 
# RUN pip install --upgrade gcloud

# Setup initial user

ENV JENKINS_USER administrator
ENV JENKINS_PASS password
ENV REPO https://github.com/Tirano2150/jenkins-casc.git

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY jenkins.init/* /usr/share/jenkins/ref/init.groovy.d/
COPY jobs/* /usr/share/jenkins/ref/jobs/

# ENV JENKINS_UC_DOWNLOAD http://jenkins-updates.cloudbees.com/download

# # back to proper install

USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY jenkins.yaml /usr/share/jenkins/ref/jenkins.yaml
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt


