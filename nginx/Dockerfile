FROM public.ecr.aws/docker/library/nginx:latest

RUN apt-get -q update -y \
    && apt-get -q install -y --no-install-recommends libnginx-mod-http-fancyindex git \
    && rm -rf /var/lib/apt/lists/*

