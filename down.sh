#!/bin/bash

source ./.env.sh

ami_id=$(cat debian-ami/ami_id.txt)

cd cdktf-aws-local-state

npm run destroy

cd ../debian-ami

sh delete-ami.sh $ami_id
