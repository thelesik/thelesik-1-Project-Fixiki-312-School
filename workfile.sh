aws_access_key_id="123123"
aws_secret_access_key="123123"
aws_output_format="yaml"
region1="us-east-1"
region2="us-east-2"
aws configure set aws_access_key_id $aws_access_key_id;
aws configure set aws_secret_access_key $aws_secret_access_key;
aws configure set default.region $region1;
aws configure set output $aws_output_format;
aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem
chmod 400 MyKeyPair.pem;

        #out-file -encoding ascii -filepath ~/MyKeyPair.pem
#:aws ec2 create-security-group --group-name NewsgGroup12;
