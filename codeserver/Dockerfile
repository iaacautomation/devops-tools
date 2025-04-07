FROM ghcr.io/coder/code-server:latest
LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/codeserver"
LABEL org.opencontainers.image.title="Code Server"
LABEL org.opencontainers.image.description="Code Server with various apps inbuilt"
LABEL build.date=20250407(YYYYMMDD)

ENV TOFU_VERSION=1.9.0
ENV DOCKER_VERSION=28.0.4
ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update && \
    sudo apt-get -y purge nano && \
    sudo apt-get -y install idn2 jq ca-certificates apt-transport-https gnupg vim unzip python3-full python3-pip virtualenv && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

RUN sudo wget --quiet -O /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

RUN wget --quiet https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar xfz docker-${DOCKER_VERSION}.tgz && \
    sudo mv docker/docker /usr/local/bin && \
    rm docker* -rf

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    sudo ./get_helm.sh && rm get_helm.sh

RUN wget --quiet https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_amd64.deb && \
    sudo dpkg -i tofu_${TOFU_VERSION}_amd64.deb && rm tofu*.deb

RUN curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&\ 
    unzip awscliv2.zip && \
    sudo ./aws/install && \
    rm aws* -rf

RUN sudo wget --quiet -O /usr/local/bin/tfsec https://github.com/aquasecurity/tfsec/releases/download/v1.28.13/tfsec-linux-amd64 && \
    sudo chmod +x /usr/local/bin/*

