FROM public.ecr.aws/docker/library/python
LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/deploy-azure"
LABEL org.opencontainers.image.title="CI/CD Tools base"
LABEL org.opencontainers.image.documentation="https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description="Docker Image with terraform ans azure for CI PIpelines"
LABEL org.opencontainers.image.base.name="public.ecr.aws/docker/library/python:3.10-bookworm"
LABEL org.opencontainers.image.revision=v4.0.4
LABEL build.date=20250407(YYYYMMDD)
ARG GITLAB_TOFU_VERSION=1.1.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get -y install idn2 jq && apt-get clean && rm -rf /var/lib/apt/lists/*
## Add OpenTofu repo
RUN curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh  && \
    chmod +x install-opentofu.sh && \
    ./install-opentofu.sh --install-method deb && \
    rm -f install-opentofu.sh

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

## Gitlab Tofu
RUN curl -L -s -o /usr/local/bin/gitlab-tofu https://gitlab.com/components/opentofu/-/raw/${GITLAB_TOFU_VERSION}/src/gitlab-tofu.sh && chmod +x /usr/local/bin/gitlab-tofu

WORKDIR /root/
CMD ["/bin/bash"]
