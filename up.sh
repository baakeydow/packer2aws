#!/bin/bash

source ./.env.sh

cd debian-ami

packer init .

output=$(packer build . 2>&1)
echo "$output"
ami_id=$(echo "$output" | grep -oE '<sensitive>: ami-\w+' | cut -d' ' -f2)

echo "$ami_id" > ami_id.txt
echo "AMI created successfully with ID: $ami_id"

cd ../cdktf-aws-local-state

npm install && npm run get && npm run deploy
