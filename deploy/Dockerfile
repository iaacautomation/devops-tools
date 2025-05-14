FROM mcr.microsoft.com/dotnet/runtime-deps:9.0 AS build

ARG TARGETARCH
ARG RUNNER_VERSION
ARG RUNNER_CONTAINER_HOOKS_VERSION
ARG DOCKER_VERSION=28.0.1
ARG BUILDX_VERSION=0.21.2
RUN apt update -y && apt install curl unzip -y
ARG HELMFILE_VERSION
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG GITLAB_TOFU_VERSION

WORKDIR /actions-runner

RUN export RUNNER_ARCH=${TARGETARCH} \
    && if [ "$RUNNER_ARCH" = "amd64" ]; then export RUNNER_ARCH=x64 ; fi \
    && curl -sfLo runner.tar.gz https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./runner.tar.gz \
    && rm runner.tar.gz

RUN curl -sfLo runner-container-hooks.zip https://github.com/actions/runner-container-hooks/releases/download/v${RUNNER_CONTAINER_HOOKS_VERSION}/actions-runner-hooks-k8s-${RUNNER_CONTAINER_HOOKS_VERSION}.zip \
    && unzip ./runner-container-hooks.zip -d ./k8s \
    && rm runner-container-hooks.zip

RUN export RUNNER_ARCH=${TARGETARCH} \
    && if [ "$RUNNER_ARCH" = "amd64" ]; then export DOCKER_ARCH=x86_64 ; fi \
    && if [ "$RUNNER_ARCH" = "arm64" ]; then export DOCKER_ARCH=aarch64 ; fi \
    && curl -fsLo docker.tgz https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz \
    && tar zxf docker.tgz \
    && rm -rf docker.tgz \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && curl -sfLo /usr/local/lib/docker/cli-plugins/docker-buildx \
        "https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-${TARGETARCH}" \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

WORKDIR /tools

## Download Tools
RUN curl -sLo kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl"
RUN curl -sfLo gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh
RUN curl -sfLo helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
RUN tar xfz helm.tar.gz && cp linux-amd64/helm /tools/
RUN curl -sfLo helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method standalone --skip-verify \
    && rm -f install-opentofu.sh
RUN tar xfz helmfile.tar.gz
RUN rm /tools/*.tar.gz /tools/linux-amd64 /tools/README* /tools/LICENSE -rf
RUN chmod +x /tools/*

FROM mcr.microsoft.com/dotnet/runtime-deps:9.0

ENV DEBIAN_FRONTEND=noninteractive
ENV RUNNER_MANUALLY_TRAP_SIG=1
ENV ACTIONS_RUNNER_PRINT_LOG_TO_STDOUT=1
ENV ImageOS=debian
ARG TAG
LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.documentation="https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"
LABEL org.opencontainers.image.base.name="mcr.microsoft.com/dotnet/runtime-deps:9.0"
LABEL org.opencontainers.image.revision=$TAG

RUN apt update -y \
    && apt install -y --no-install-recommends sudo curl jq unzip git openssh-client ansible-lint ansible nodejs bash python3-yaml python3-kubernetes \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" --uid 1001 runner \
    && groupadd docker --gid 123 \
    && usermod -aG sudo runner \
    && usermod -aG docker runner \
    && echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers \
    && echo "Defaults env_keep += \"DEBIAN_FRONTEND\"" >> /etc/sudoers

## Get All tools fromo build image
COPY --from=build /tools/* /usr/local/bin/
COPY --from=build /opt/opentofu/tofu /usr/local/bin

## Install helm plugins
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN /usr/local/bin/helm plugin install https://github.com/databus23/helm-diff && helmfile init --force && rm /root/.cache -rf

## Disable hosts key check for ssh (ansible and tofu ssh git)
RUN echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config

WORKDIR /home/runner

COPY --chown=runner:docker --from=build /actions-runner .
COPY --from=build /usr/local/lib/docker/cli-plugins/docker-buildx /usr/local/lib/docker/cli-plugins/docker-buildx

RUN install -o root -g root -m 755 docker/* /usr/bin/ && rm -rf docker

USER runner