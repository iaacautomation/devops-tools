ARG DISTRO
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH 
WORKDIR /tmp

FROM debian:$DISTRO as build
ENV DEBIAN_FRONTEND=noninteractive 
WORKDIR /tmp/
RUN apt-get update 
RUN apt-get -y dist-upgrade 
RUN apt-get install -y golint apt-transport-https golang curl gnupg git build-essential
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
RUN apt-get update
RUN apt-get install -y helm
RUN git clone https://github.com/databus23/helm-diff
RUN cd ${WORKDIR}/helm-diff
RUN make install

FROM debian:${DISTRO} as base
RUN mkdir /workdir
COPY awscli.sh /workdir/

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update apt-get install -y jq curl wget git unzip ca-certificates curl gnupg lsb-release apt-transport-https

## Setup Kubectl repo
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

## Setup Helm
RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
COPY --from=build /plugins/ /plugins/

FROM base
ENV DEBIAN_FRONTEND=noninteractive 
WORKDIR /workdir
### Install All requirements
RUN apt-get update && apt-get install -y kubectl helm && rm -rf /var/lib/apt/lists

### Install helmfile
RUN wget -O /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/download/v0.142.0/helmfile_linux_${TARGETARCH}  && chmod +x /usr/local/bin/helmfile

### Install Terraform
ARG TERRAFORM_VERSION=1.0.10
RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -o terraform.zip && unzip terraform.zip && chmod +x terraform && mv terraform /usr/local/bin/ && rm terraform* -rf


### Install tfenv
RUN git clone https://github.com/tfutils/tfenv.git && cd /tmp/tfenv && git checkout v2.2.2 && rm -rf .git .github .gitignore .travis.yml *.md test && cd /tmp/ && mv tfenv /usr/local/
ENV PATH=$PATH:/usr/local/tfenv/bin

# Install AWS CLI
RUN bash -x awscli.sh $TARGETARCH && rm /workdir -rf

CMD ["/bin/bash"]
