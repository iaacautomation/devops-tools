#!/bin/bash
TARGETARCH=$1
cd /tmp/
if [[ $TARGETARCH == "amd64" ]]
then 
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
elif [[ $TARGETARCH = "arm64" ]]
then 
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"  -o "awscliv2.zip" 
fi 
if [[ -f awscliv2.zip ]]
then
  unzip -q awscliv2.zip && ./aws/install --update && rm -rf aws awscliv2.zip
fi
