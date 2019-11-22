FROM google/cloud-sdk:latest

# Update and install tools
RUN apt-get install -y google-cloud-sdk-app-engine-java \
    kubectl \
    jq \
    nodejs \
    apache2-utils \
    vim

# Install Helm
RUN curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash