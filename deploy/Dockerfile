ARG DISTRO
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH

FROM python:3 as build
ENV VENV_PATH=/opt/packages \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1  
RUN python3 -m venv --copies $VENV_PATH
ENV PATH="$VENV_PATH/bin:$PATH"
RUN pip3 install checkov ansible ansible-lint sarif-tools --no-cache-dir

FROM debian:${DISTRO}
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "Deployment Image for CI PIpelines"
LABEL org.opencontainers.image.base.name "debian:${DISTRO}"
LABEL org.opencontainers.image.revision v1.6.0
LABEL build.date 20220522(YYYYMMDDhhmm)
ARG TARGETARCH
ENV TERRAFORM_VERSION=1.2.1
ENV TFSEC_VERSION=1.21.2
ENV TFENV_VERSION=v2.2.3

### Install utilities and packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update &&  apt-get install --no-install-recommends -y jq python3-distutils libpython3.10-dev curl wget git unzip ca-certificates curl gnupg apt-transport-https nodejs npm openssh-client && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

## Setup Kubernetes key and repo for kubectl
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list 

## Setup helm key and repo
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list 

## Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git /usr/local/tfenv && cd /usr/local/tfenv && git checkout ${TFENV_VERSION} && rm -rf .git .github .gitignore .travis.yml *.md test 

## Install helmfile
RUN wget -q -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_${TARGETARCH}  && chmod +x /usr/local/bin/helmfile 

## Install Hashicorp key and repo (Disabled because no arm64 apt repo)
# RUN wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" > /etc/apt/sources.list.d/terraform.list
RUN wget -q -O /usr/local/bin/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && unzip /usr/local/bin/terraform.zip && rm /usr/local/bin/terraform.zip && mv terraform /usr/local/bin && chmod +x /usr/local/bin/terraform

## Install kubectl and helm and docker cli
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y kubectl helm && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

### Add tfsec
RUN wget https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-${TARGETARCH} -O /usr/local/bin/tfsec && chmod +x /usr/local/bin/tfsec

COPY awscli.sh /tmp/
RUN bash /tmp/awscli.sh ${TARGETARCH} && rm /tmp/aws* -rf

ENV VIRTUAL_ENV=/opt/packages
COPY --from=build $VIRTUAL_ENV $VIRTUAL_ENV
COPY gitlab-terraform.sh /usr/local/bin/gitlab-terraform
ENV PATH=$VIRTUAL_ENV/bin:$PATH:/usr/local/tfenv/bin
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN helm plugin install https://github.com/databus23/helm-diff && rm /root/.cache -rf
CMD ["/bin/bash"]