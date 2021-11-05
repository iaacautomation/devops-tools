FROM --platform=$BUILDPLATFORM golang:alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG DISTRO
FROM debian:${DISTRO}
WORKDIR /tmp

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y jq curl wget git unzip ca-certificates curl gnupg apt-transport-https apt-utils python3-pip net-tools dosfstools bind9-dnsutils dnsutils bridge-utils cifs-utils debianutils findutils moreutils telnet netcat-openbsd

CMD ["/bin/bash"]
