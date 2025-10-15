FROM public.ecr.aws/docker/library/nginx:latest

RUN sudo apt-get -q update -y \
    && sudo apt-get -q install -y --no-install-recommends libnginx-mod-http-fancyindex git \
    && sudo rm -rf /var/lib/apt/lists/*

