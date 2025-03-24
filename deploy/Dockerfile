FROM --platform=$BUILDPLATFORM public.ecr.aws/docker/library/golang:alpine AS build
ARG TARGETPLATFORM
ARG BUILDPLATFORM

FROM public.ecr.aws/docker/library/alpine:latest
LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.documentation="https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"
LABEL org.opencontainers.image.base.name="alpine:latest"
LABEL org.opencontainers.image.revision v4.0.4
LABEL build.date=20241026(YYYYMMDD)
ARG HELMFILE_VERSION=0.170.0
ARG GITLAB_TOFU_VERSION=0.50.0
ARG TARGETARCH
WORKDIR /tmp

## Add OpenTofu repo
RUN echo '@community https://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories

### Install utilities and packages
RUN apk add curl git bash nodejs openssh-client ansible ansible-lint openssl idn2-utils jq py3-boto3 py3-yaml opentofu@community py3-kubernetes

## Install Kubectl
RUN curl -L -s -o /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && chmod +x /usr/local/bin/kubectl

## Install Helm
RUN curl -L -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Install helmfile
RUN curl -L -o /tmp/helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz  && tar xfz /tmp/helmfile.tar.gz  && mv /tmp/helmfile /usr/local/bin/ && chmod +x /usr/local/bin/helmfile && rm /tmp/*

## Gitlab Tofu
RUN curl -L -s -o /usr/local/bin/gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh && chmod +x /usr/local/bin/gitlab-tofu

ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN helm plugin install https://github.com/databus23/helm-diff && helmfile init --force && rm /root/.cache -rf

WORKDIR /root/ 
CMD ["/bin/bash"]