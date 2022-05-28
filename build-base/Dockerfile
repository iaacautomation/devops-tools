ARG DISTRO
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH 

FROM debian:$DISTRO as build
ENV DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.authors "Manpreet Singh Nehra"
LABEL org.opencontainers.image.source "https://github.com/iaacautomation/devops-tools/tree/main/deploy"
LABEL org.opencontainers.image.title "CI/CD Tools base"
LABEL org.opencontainers.image.documentation "https://github.com/iaacautomation/devops-tools"
LABEL org.opencontainers.image.description "Deployment Image for CI PIpelines"
LABEL org.opencontainers.image.base.name "debian:${DISTRO}"
LABEL org.opencontainers.image.revision v1.6.0
LABEL build.date 20220522(YYYYMMDDhhmm)
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y golint apt-transport-https golang curl gnupg git build-essential python3-pip python3-venv golang && rm /var/lib/apt/list/* -rf

