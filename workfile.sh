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
sgid=$(aws ec2 create-security-group --description newsgforcli --group-name NewsgGroup12 | jq -r '.GroupId');
#
# HERE YOU SHOULD ADD HTTP 80 poer and SSh 22 port
#
#
#

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
# script will be running 10 minutes
instanceid=$(jq -r '.Instances[0].InstanceId' logs.json);
imageid=$(aws ec2 create-image --instance-id $instanceid --name NewAMIforclitask1awsadvanced123 | jq -r '.ImageId';)
echo $imageid;
newimageid2=$(aws ec2 copy-image --source-image-id $imageid --source-region us-east-1 --region us-east-2 --name "ami-NewAMIforclitask1awsadvanced1234");
echo $newimageid2;

# 2nd part creation of new instance on another region
aws configure set aws_access_key_id $aws_access_key_id;
aws configure set aws_secret_access_key $aws_secret_access_key;
aws configure set default.region $region2;
aws configure set output $aws_output_format;

aws ec2 create-key-pair --key-name MyKeyPair2 --query 'KeyMaterial' --output text > MyKeyPair2.pem;
chmod 400 MyKeyPair2.pem;
sgid2=$(aws ec2 create-security-group --description newsgforcli --group-name NewsgGroup12 | jq -r '.GroupId');
#
# HERE YOU SHOULD ADD HTTP 80 poer and 22
newimageid3=$(aws ec2 copy-image --source-image-id $imageid --source-region us-east-1 --region us-east-2 --name "ami-NewAMIforclitask1awsadvanced1234");
echo $newimageid3;
sleep 15;
subnetid2=$(aws ec2 describe-subnets | jq -r '.Subnets[0].SubnetId');
aws ec2 run-instances --image-id $newimageid2 --instance-type t2.micro --count 1 --subnet-id $subnetid2 --security-group-ids $sgid2 --key-name MyKeyPair2 > logs2.json;
