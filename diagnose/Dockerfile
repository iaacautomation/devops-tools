ARG DISTRO
FROM --platform=$BUILDPLATFORM debian:${DISTRO}
WORKDIR /tmp
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&  apt-get install -y jq curl wget git unzip ca-certificates curl gnupg apt-transport-https apt-utils python3-pip net-tools dosfstools bind9-dnsutils dnsutils bridge-utils cifs-utils debianutils findutils moreutils telnet netcat-openbsd

CMD ["/bin/bash"]
