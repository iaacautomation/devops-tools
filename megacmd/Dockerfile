FROM public.ecr.aws/docker/library/debian:stable-slim

ENV DEBIAN_FRONTEND=non-interactive

RUN apt-get update && \
    apt-get -y install wget && \
    wget https://mega.nz/linux/repo/Debian_12/amd64/megacmd-Debian_12_amd64.deb && \
    apt-get -y install "$PWD/megacmd-Debian_12_amd64.deb" && \
    rm *.deb && \
    apt-get purge -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y
    
ENTRYPOINT ["mega-cmd-server"]    