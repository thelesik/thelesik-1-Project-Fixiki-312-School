aws_access_key_id=""
aws_secret_access_key=""
aws_output_format="json"
region1="us-east-1"
region2="us-east-2"
aws configure set aws_access_key_id $aws_access_key_id;
aws configure set aws_secret_access_key $aws_secret_access_key;
aws configure set default.region $region1;
aws configure set output $aws_output_format;
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem;
chmod 400 MyKeyPair.pem;
sgid=$(aws ec2 create-security-group --description newsgforcli --group-name NewsgGroup12 | jq -r '.GroupId');

aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 22 --cidr 0.0.0.0/0 > SGfilelogs.json;
aws ec2 authorize-security-group-ingress --group-id $sgid --protocol tcp --port 80 --cidr 0.0.0.0/0 >> SGfilelogs.json;


subnetid=$(aws ec2 describe-subnets | jq -r '.Subnets[0].SubnetId');
aws ec2 run-instances --image-id ami-0f9fc25dd2506cf6d --instance-type t2.nano --count 1 --subnet-id $subnetid --security-group-ids $sgid --key-name MyKeyPair > logs.json;
instanceid=$(jq -r '.Instances[0].InstanceId' logs.json);
sleep 10;
aws ec2 wait instance-running --instance-ids ${instanceid};
echo "Instance ${instanceid} is running ";
#get public ip
publicip=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=instance-id,Values= ${instanceid}" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text);
#
#
#ssh part

touch free.txt;

echo "First mashine " > free.txt
sleep 10;
ssh -o "StrictHostKeyChecking=no" ec2-user@${publicip};
#ssh-keyscan -H ${publicip} >> ~/.ssh/known_hosts;
#ssh -i MyKeyPair.pem ec2-user@${publicip};
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo amazon-linux-extras install nginx1 -y';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo systemctl enable nginx';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo systemctl status nginx';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo systemctl start nginx';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo systemctl enable nginx';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo systemctl status nginx';
sleep 2;
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo wget -O /usr/share/nginx/html/alexabuy.jpg https://i.redd.it/v7exkf93r34z.jpg';
#ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'sudo su';
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'echo "<html> <img src=\"alexabuy.jpg\" alt=\"Alexa Buy Whole Foods\"> </html>" | sudo tee /usr/share/nginx/html/index.html';
ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'free -m' >> free.txt;

#
#
#end of ssh part


#create image
imageid=$(aws ec2 create-image --instance-id $instanceid --name NewAMIforclitask1awsadvanced123 | jq -r '.ImageId';)
#Image creation
aws ec2 wait image-available --image-ids ${imageid};
sleep 5;
echo "AMI image on ${region1} is created AMI id is ${imageid}";

#copy AMI
newimageid2=$(aws ec2 copy-image --source-image-id $imageid --source-region us-east-1 --region us-east-2 --name "ami-NewAMIforclitask1awsadvanced1234" | jq -r '.ImageId';);
echo "AMI is copied to ${region2} AMI id ${newimageid2}";

#aws ec2 wait image-available --image-ids ${newimageid2};


# 2nd part creation of new instance on another region
#aws configure set aws_access_key_id $aws_access_key_id;
#aws configure set aws_secret_access_key $aws_secret_access_key;
aws configure set default.region $region2;
aws configure set output $aws_output_format;

aws ec2 create-key-pair --key-name MyKeyPair2 --query 'KeyMaterial' --output text > MyKeyPair2.pem;
chmod 400 MyKeyPair2.pem;
sgid2=$(aws ec2 create-security-group --description newsgforcli --group-name NewsgGroup12 | jq -r '.GroupId');
# add port
aws ec2 authorize-security-group-ingress --group-id $sgid2 --protocol tcp --port 22 --cidr 0.0.0.0/0 >> SGfilelogs.json;
aws ec2 authorize-security-group-ingress --group-id $sgid2 --protocol tcp --port 80 --cidr 0.0.0.0/0 >> SGfilelogs.json;
# get subnet info
subnetid2=$(aws ec2 describe-subnets | jq -r '.Subnets[0].SubnetId');

aws ec2 wait image-available --image-ids ${newimageid2};
sleep 5;
#aws ec2 wait image-available --image-ids ${newimageid2};

aws ec2 run-instances --image-id $newimageid2 --instance-type t2.micro --count 1 --subnet-id $subnetid2 --security-group-ids $sgid2 --key-name MyKeyPair2 > logs2.json;
instanceid2=$(jq -r '.Instances[0].InstanceId' logs2.json);
sleep 5;
aws ec2 wait instance-running --instance-ids ${instanceid2};
publicip2=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=instance-id,Values= ${instanceid2}" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text);
aws ec2 wait instance-running --instance-ids ${instanceid2};
echo "Second mashine " >> free.txt;
#ssh-keyscan -H ${publicip2} >> ~/.ssh/known_hosts;
aws ec2 wait instance-running --instance-ids ${instanceid2};
ssh -o "StrictHostKeyChecking=no" ec2-user@${publicip2};
ssh -i MyKeyPair.pem ec2-user@${publicip2} -t 'free -m' >> free.txt;

# wait
# ssh -i MyKeyPair.pem ec2-user@${publicip} -t 'free -m' > free.txt;
#aws ec2 wait instance-running --instance-ids ${instanceid};
#echo "Instance ${instanceid} is running ";
#get public ip
#publicip=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=instance-id,Values= ${instanceid}" --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text);

echo "Results are saved to free.txt";
cat free.txt;
echo "Done";
