ARG DISTRO
FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH 

FROM debian:$DISTRO as build
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get update && apt-get -y dist-upgrade && apt-get install -y golint apt-transport-https golang curl gnupg git build-essential python3-pip python3-venv golang && rm /var/lib/apt/list/* -rf

