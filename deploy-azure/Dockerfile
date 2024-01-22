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
LABEL org.opencontainers.image.revision v2.6.2
LABEL build.date 20240122(YYYYMMDD)
ENV DEBIAN_FRONTEND=noninteractive
ARG GITLAB_TERRAFORM_VERSION=v1.7.1
ARG TARGETARCH

### Install idn2 for azure
RUN apk add idn2-utils curl

##Install OpenTofu
RUN echo '@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && apk add opentofu@testing
RUN wget https://gitlab.com/gitlab-org/terraform-images/-/raw/${GITLAB_TERRAFORM_VERSION}/src/bin/gitlab-terraform.sh -O /usr/local/bin/gitlab-terraform && chmod +x /usr/local/bin/gitlab-terraform  && ln -s /usr/bin/tofu /usr/bin/terraform  

WORKDIR /root/
CMD ["/bin/bash"]
