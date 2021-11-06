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
RUN make install

FROM debian:${DISTRO}
ARG TARGETARCH 
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get install -y jq curl wget git unzip ca-certificates curl gnupg lsb-release apt-transport-https

## Setup Kubectl repo
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Setup Helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list

### Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git  /usr/local/tfenv && cd /usr/local/tfenv && git checkout v2.2.2 && rm -rf .git .github .gitignore .travis.yml *.md test

### Install All requirements
RUN apt-get update && apt-get install -y kubectl helm && apt-get clean && rm -rf /var/lib/apt/lists/* -rf

### Install helmfile
RUN wget -q -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.142.0/helmfile_linux_${TARGETARCH}  && chmod +x /usr/local/bin/helmfile

### Install Terraform
ARG TERRAFORM_VERSION=1.0.10
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && unzip terraform.zip && chmod +x terraform && mv terraform /usr/local/bin/

# Install AWS CLI
COPY awscli.sh /tmp/
RUN bash /tmp/awscli.sh $TARGETARCH && rm /tmp/* -rf

### Add User 
RUN groupadd -g 10001 deploy && useradd -g 10001 -u 10001 -s /bin/bash -m deploy
COPY --from=build /plugins/ /home/deploy/.local/share/helm/plugins/ 
RUN chown deploy:deploy /home/deploy -R
USER deploy
ENV PATH=$PATH:/usr/local/tfenv/bin
WORKDIR /home/deploy/
CMD ["/bin/bash"]