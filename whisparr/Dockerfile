FROM debian:trixie-slim

ARG TARGETPLATFORM
ARG CHANNEL

ENV COMPlus_EnableDiagnostics="0" \
    WHISPARR__UPDATE__BRANCH="${CHANNEL}" \
    UMASK="0002" \
    TZ="Etc/UTC" \
    DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get -y install \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        sqlite3 \
        libicu* \
    && \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='x64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
    esac \
    && \
    mkdir -p /app/bin \
    && \
    curl -fsSL "http://whisparr.servarr.com/v1/update/${WHISPARR__UPDATE__BRANCH}/updatefile?os=linux&runtime=netcore&arch=${ARCH}" \
        | tar xzf - -C /app/bin --strip-components=1 \
    && \
    rm -rf /app/bin/Whisparr.Update \
    && \
    printf "UpdateMethod=docker\nBranch=%s\nPackageVersion=%s\nPackageAuthor=[iaacautomation](https://github.com/iaacautomation)\n" "${WHISPARR__UPDATE__BRANCH}"> /app/package_info \
    && chown -R root:root /app \
    && chmod -R 755 /app \
    && rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

ENTRYPOINT ["/usr/bin/catatonit", "--"]
CMD ["/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/Whisparr/Whisparr"
