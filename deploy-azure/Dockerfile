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
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy-azure"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "CI Tools Image for CI PIpelines"
LABEL org.opencontainers.image.base.name "debian:${DISTRO}"
LABEL org.opencontainers.image.revision v2.0.1
LABEL build.date 20220801(YYYYMMDDhhmm))
ENV TERRAFORM_VERSION=1.3.5
ENV TFENV_VERSION=v3.0.0
ENV DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH

### Install utilities and packages
RUN apt-get update &&  apt-get install --no-install-recommends -y jq libpython3.11 curl wget git unzip ca-certificates curl gnupg apt-transport-https nodejs openssh-client idn2 && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

## Setup Azure key and repo
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && echo "deb [arch=${TARGETARCH}] https://packages.microsoft.com/repos/azure-cli/ bullseye main" |  tee /etc/apt/sources.list.d/azure-cli.list

# RUN wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" > /etc/apt/sources.list.d/terraform.list
RUN wget -q -O /usr/local/bin/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && unzip /usr/local/bin/terraform.zip && rm /usr/local/bin/terraform.zip && mv terraform /usr/local/bin && chmod +x /usr/local/bin/terraform

## Install kubectl and helm and docker cli
RUN apt-get update && apt-get install -y azure-cli && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

ENV VIRTUAL_ENV=/opt/packages
COPY --from=build $VIRTUAL_ENV $VIRTUAL_ENV
COPY gitlab-terraform.sh /usr/local/bin/gitlab-terraform
ENV PATH=$VIRTUAL_ENV/bin:$PATH:/usr/local/tfenv/bin
CMD ["/bin/bash"]
