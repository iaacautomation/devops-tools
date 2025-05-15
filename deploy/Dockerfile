FROM ghcr.io/actions/actions-runner:latest

LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.description="CI Tools Image for CI PIpelines"

ARG TARGETARCH
ARG HELMFILE_VERSION
ARG KUBECTL_VERSION
ARG HELM_VERSION
ARG GITLAB_TOFU_VERSION

RUN sudo apt-get -q update -y \
    && sudo apt-get -q install -y --no-install-recommends sudo lsb-release gpg-agent software-properties-common curl jq unzip git openssh-client ansible-lint ansible nodejs bash python3-yaml python3-kubernetes \
    && sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/runner/tools

## Download Tools
RUN curl -sLo kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl"
RUN curl -sfLo helm.tar.gz https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
RUN tar xfz helm.tar.gz && cp linux-amd64/helm .
RUN curl -sfLo gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh
RUN curl -sfLo helmfile.tar.gz https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${TARGETARCH}.tar.gz
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && sudo ./install-opentofu.sh --install-method standalone --skip-verify \
    && rm -f install-opentofu.sh
RUN tar xfz helmfile.tar.gz
RUN rm *.gz linux-amd64 README* LICENSE -rf
RUN chmod +x *

RUN curl -sfL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip -qq awscliv2.zip && sudo ./aws/install && rm awscliv2.zip aws -rf

RUN ls -l && sudo cp * /usr/local/bin/

ENV HELM_PLUGINS=/usr/local/share/helm/plugins
RUN sudo /usr/local/bin/helm plugin install https://github.com/databus23/helm-diff && sudo helmfile init --force && sudo rm /root/.cache -rf

RUN echo "    StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config

USER runner