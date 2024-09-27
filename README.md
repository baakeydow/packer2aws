# packer2aws

Use packer to create a custom Debian based AMI with SSH support

## Setup

- Create a file named `.env.sh` in the root folder with =>

```bash
#!/bin/bash
export AWS_REGION=eu-west-1
export AWS_OWNER_ID=424242424242
export EC2_INSTANCE_TYPE=t2.micro
```  

- Create a ssh key named `rsa.pub` in the debian-ami folder

## Deploy

> `sh up.sh`

## Destroy

> `sh down.sh`