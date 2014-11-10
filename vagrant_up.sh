#!/bin/sh 
set -x


OLD_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Live,Values=$LIVEVAL"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

aws ec2 create-tags --resources $OLD_INSTANCE_ID --tags Key=Old,Value=true

VAGRANT_LOG=debug AWSNAME=${JOB_NAME}-${BUILD_NUMBER} vagrant up --provider=aws
