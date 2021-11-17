ARG DISTRO
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH 

FROM ghcr.io/iaacautomation/devops-tools/build as build
ENV DEBIAN_FRONTEND=noninteractive 
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install -y helm
RUN git clone https://github.com/databus23/helm-diff /helm-diff
WORKDIR /helm-diff
RUN git checkout v3.1.3 && make install

FROM debian:${DISTRO}
LABEL org.opencontainers.image.authors="Manpreet Singh Nehra"
LABEL org.opencontainers.image.source="https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title="CI/CD base"
LABEL org.opencontainers.image.documentation="https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description="Deployment Image for CI PIpelines"
LABEL org.opencontainers.image.base.name="debian:bookworm-slim"
ARG TARGETARCH TERRAFORM_VERSION=1.0.11
COPY awscli.sh /tmp/

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y jq curl wget git unzip ca-certificates curl gnupg lsb-release apt-transport-https && rm -rf /var/lib/apt/lists/* -rf

## Setup Kubectl, Helm, tfenv, terraform, aws cli
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
  && curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
  && git clone https://github.com/tfutils/tfenv.git  /usr/local/tfenv && cd /usr/local/tfenv && git checkout v2.2.2 && rm -rf .git .github .gitignore .travis.yml *.md test \
  && wget -q -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.142.0/helmfile_linux_${TARGETARCH}  && chmod +x /usr/local/bin/helmfile \
  && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && unzip terraform.zip && chmod +x terraform && mv terraform /usr/local/bin/ \
  && bash /tmp/awscli.sh $TARGETARCH && rm /tmp/* -rf 


RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y kubectl helm && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

### Add User 
COPY --from=build /plugins/ /root/.local/share/helm/plugins/ 
ENV PATH=$PATH:/usr/local/tfenv/bin
CMD ["/bin/bash"]
