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
RUN pip3 install ansible ansible-lint six --no-cache-dir

FROM debian:${DISTRO}
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "CI Tools Image for CI PIpelines"
LABEL org.opencontainers.image.base.name "debian:${DISTRO}"
LABEL org.opencontainers.image.revision v2.5.5
LABEL build.date 20230810(YYYYMMDD))
ARG TERRAFORM_VERSION=1.5.7
ENV DEBIAN_FRONTEND=noninteractive
ARG HELMFILE_VERSION=0.157.0
ARG GITLAB_TERRAFORM_VERSION=v1.5.0
ARG TARGETARCH
WORKDIR /tmp

### Install utilities and packages
RUN apt-get update &&  apt-get install --no-install-recommends -y jq libpython3.11 curl wget git unzip ca-certificates curl gnupg apt-transport-https nodejs openssh-client idn2 && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

## Setup Kubernetes key and repo for kubectl
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Setup helm key and repo
RUN curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list 

## Install helmfile
RUN wget -q -O helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz  && tar xfz helmfile.tar.gz  && mv helmfile /usr/local/bin/ && chmod +x /usr/local/bin/helmfile && rm helmfile* -rf

## Install Hashicorp key and repo (Disabled because no arm64 apt repo)
# RUN wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" > /etc/apt/sources.list.d/terraform.list
RUN wget -q -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && unzip terraform.zip  && mv terraform /usr/local/bin && chmod +x /usr/local/bin/terraform && rm terraform* -fr

## Install kubectl and helm and docker cli
RUN apt-get update && apt-get install -y kubectl helm && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

ENV VIRTUAL_ENV=/opt/packages
COPY --from=build $VIRTUAL_ENV $VIRTUAL_ENV
RUN wget https://gitlab.com/gitlab-org/terraform-images/-/raw/${GITLAB_TERRAFORM_VERSION}/src/bin/gitlab-terraform.sh -O /usr/local/bin/gitlab-terraform && chmod +x /usr/local/bin/gitlab-terraform
ENV PATH=$VIRTUAL_ENV/bin:$PATH:/usr/local/tfenv/bin
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN helm plugin install https://github.com/databus23/helm-diff && helmfile init --force && rm /root/.cache -rf

WORKDIR /root/
CMD ["/bin/bash"]
