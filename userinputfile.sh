#!/bin/bash

1key=“AKIAQ4DCTGUDWXWAXDUB”
2key=“+oKyL6zezDGb6JnzR/3VuThe6bBZN7SbDlhoAHjf”
region1=“us-east-1”
region2=“us-east-2”
format=“json”
instanceid=$"aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].{Instance:InstanceId}' --output text";
publicip=$"aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=instance-id,Values= ${instanceid}" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text";
aws configure set aws_access_key_id ${1key};
aws configure set aws_secret_access_key ${2key};
aws configure set default.region $region1;
aws configure set default.region $region2;
aws configure set output $format;
aws ec2 create-key-pair --key-name project_keypair --query 'KeyMaterial' --output text > project_keypair.pem;
chmod 400 project_keypair.pem;
ssh -o StrictHostKeyChecking=no -i project_keypair.pem ec2-user@${publicip} -t 'sudo amazon-linux-extras install nginx1 -y;sudo systemctl start nginx;sudo systemctl enable nginx;sudo systemctl status nginx;sudo wget -O /usr/share/nginx/html/alexabuy.jpg https://i.redd.it/v7exkf93r34z.jpg;
