FROM public.ecr.aws/docker/library/debian:latest

RUN apt-get -q update -y \
    && apt-get -q install -y nginx-full libnginx-mod-* git \
    && rm -rf /var/lib/apt/lists/*

COPY default.conf /etc/nginx/sites-available/default

CMD ["nginx","-c","/etc/nginx/nginx.conf"] 