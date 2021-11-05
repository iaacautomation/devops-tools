ARG DISTRO
FROM --platform=$BUILDPLATFORM debian:${DISTRO} as base
WORKDIR /tmp
COPY awscli.sh /tmp/
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y jq curl wget git unzip ca-certificates curl gnupg lsb-release apt-transport-https apt-utils

FROM base as kubernetes
## Setup Kubectl repo
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Setup Helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

### Install helmfile
RUN curl https://github.com/roboll/helmfile/releases/download/v0.142.0/helmfile_linux_${TARGETARCH} -o /usr/local/bin/helmfile && chmod +x /usr/local/bin/helmfile

### Install All requirements
RUN apt-get update && apt-get install -y kubectl helm && rm -rf /var/lib/apt/lists

FROM base as terraform
### Install Terraform
ARG TERRAFORM_VERSION=1.0.10
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && unzip terraform.zip && chmod +x terraform && mv terraform /usr/local/bin/ && rm terraform* -rf


### Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git && cd /tmp/tfenv && git checkout v2.2.2 && rm -rf .git .github .gitignore .travis.yml *.md test && cd /tmp/ && mv tfenv /usr/local/
ENV PATH=$PATH:/usr/local/tfenv/bin

# Install AWS CLI
RUN bash -x awscli.sh $TARGETARCH && rm /tmp/* -rf

CMD ["/bin/bash"]
