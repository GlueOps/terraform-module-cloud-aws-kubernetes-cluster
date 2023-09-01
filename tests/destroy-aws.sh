#!/usr/bin/env bash

# reference: https://github.com/GlueOps/scripts-teardown-aws-amazon-web-services
echo "Preform an AWS Cleanup with AWS Nuke"
wget https://github.com/rebuy-de/aws-nuke/releases/download/v2.24.2/aws-nuke-v2.24.2-linux-amd64.tar.gz && tar -xvf aws-nuke-v2.24.2-linux-amd64.tar.gz && rm aws-nuke-v2.24.2-linux-amd64.tar.gz && mv aws-nuke-v2.24.2-linux-amd64 aws-nuke
./aws-nuke -c aws-nuke.yaml --no-dry-run --force
