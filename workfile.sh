aws_access_key_id=""
aws_secret_access_key=""
aws_output_format="json"
region1="us-east-1"
region2="us-east-2"
aws configure set aws_access_key_id $aws_access_key_id;
aws configure set aws_secret_access_key $aws_secret_access_key;
aws configure set default.region $region1;
aws configure set output $aws_output_format;
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem;
sgid=$(aws ec2 create-security-group --description newsgforcli --group-name NewsgGroup12 | jq -r '.GroupId'); #need to find id of thias SG:
subnetid=$(aws ec2 describe-subnets | jq -r '.Subnets[1].SubnetId');
aws ec2 run-instances --image-id ami-0f9fc25dd2506cf6d --instance-type t2.nano --count 1 --subnet-id $subnetid --security-group-ids $sgid --key-name MyKeyPair > logs.json;

#
#
#
#
#
#
#
#
#CODE FOR WEB SERVER
sleep 30;
instanceid=$(jq -r '.Instances[0].InstanceId' logs.json);
aws ec2 create-image --instance-id $instanceid --name NewAMIforclitask1awsadvanced123;
