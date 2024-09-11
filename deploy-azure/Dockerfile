FROM mcr.microsoft.com/azure-cli
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy-azure"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "Docker Image with terraform ans azure for CI PIpelines"
LABEL org.opencontainers.image.base.name "mcr.microsoft.com/azure-cli"
LABEL org.opencontainers.image.revision v2.6.5
LABEL build.date 20240213(YYYYMMDD)
ARG GITLAB_TOFU_VERSION=0.27.0

## Add OpenTofu repo
RUN echo '@community https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories

### Install idn2 for azure
RUN apk add idn2-utils curl git opentofu@community

## Gitlab Tofu
RUN curl -L -s -o /usr/local/bin/gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh && chmod +x /usr/local/bin/gitlab-tofu

WORKDIR /root/
CMD ["/bin/bash"]
