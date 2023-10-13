FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM mcr.microsoft.com/azure-cli
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy-azure"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "Docker Image with terraform ans azure for CI PIpelines"
LABEL org.opencontainers.image.base.name "mcr.microsoft.com/azure-cli"
LABEL org.opencontainers.image.revision v2.6.1
LABEL build.date 20231013(YYYYMMDDhhmm))
ARG TERRAFORM_VERSION=1.6.1
ENV DEBIAN_FRONTEND=noninteractive
ARG GITLAB_TERRAFORM_VERSION=v1.6.0
ARG TARGETARCH

### Install idn2 for azure
RUN apk add idn2-utils

### RUN wget -qO - terraform.gpg https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/terraform-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/terraform-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" > /etc/apt/sources.list.d/terraform.list
RUN wget -q -O /usr/local/bin/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip && unzip /usr/local/bin/terraform.zip && rm /usr/local/bin/terraform.zip && mv terraform /usr/local/bin && chmod +x /usr/local/bin/terraform
RUN wget https://gitlab.com/gitlab-org/terraform-images/-/raw/${GITLAB_TERRAFORM_VERSION}/src/bin/gitlab-terraform.sh -O /usr/local/bin/gitlab-terraform && chmod +x /usr/local/bin/gitlab-terraform

WORKDIR /root/
CMD ["/bin/bash"]
