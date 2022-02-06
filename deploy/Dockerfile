ARG DISTRO
ARG TERRAFORM_VERSION
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH 

FROM ghcr.io/iaacautomation/devops-tools/build as build
ENV DEBIAN_FRONTEND=noninteractive
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
#RUN apt-get update
#RUN apt-get install -y helm
#RUN git clone https://github.com/databus23/helm-diff /helm-diff
#WORKDIR /helm-diff
#RUN git checkout v3.4.0 && make install
ENV PATH="/opt/ansible/bin:$PATH"
RUN python3 -m venv /opt/ansible
RUN pip3 install ansible six jmespath distlib ansible-lint

FROM debian:${DISTRO}
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "Deployment Image for CI PIpelines"
LABEL org.opencontainers.image.base.name "debian:bookworm-slim"
ARG TARGETARCH 

### Copy awscli install script
COPY awscli.sh /tmp/

### Install utilities and packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y jq curl wget git unzip ca-certificates curl gnupg lsb-release apt-transport-https  && rm -rf /var/lib/apt/lists/* -rf

## Setup Kubernetes key and repo for kubectl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list 

## Setup helm key and repo
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list 

## Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git  /usr/local/tfenv && cd /usr/local/tfenv && git checkout v2.2.2 && rm -rf .git .github .gitignore .travis.yml *.md test 

## Install helmfile
RUN wget -q -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.142.0/helmfile_linux_${TARGETARCH}  && chmod +x /usr/local/bin/helmfile 

## Install terraform
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && unzip terraform.zip && chmod +x terraform && mv terraform /usr/local/bin/ && rm terraform.zip

## Install awscli
RUN bash /tmp/awscli.sh $TARGETARCH && rm /tmp/* -rf 

## Install kubectl and helm and docker cli
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y kubectl helm && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

## Install Clusterctl
RUN curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.0.2/clusterctl-linux-amd64 -o clusterctl && mv clusterctl /usr/local/bin/clusterctl && chmod +x /usr/local/bin/clusterctl

### Add User 
#COPY --from=build /plugins/ /usr/local/share/helm/plugins/ 

COPY --from=build /opt/ansible /opt/ansible
ENV PATH=/opt/ansible/bin:$PATH:/usr/local/tfenv/bin
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN helm plugin install https://github.com/databus23/helm-diff
CMD ["/bin/bash"]
