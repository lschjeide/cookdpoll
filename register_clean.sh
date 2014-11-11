#!/bin/sh 
set -x

NEW_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

aws elb register-instances-with-load-balancer --load-balancer-name $ELB --instances $NEW_INSTANCE_ID

OLD_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Live,Values=$DEADVAL"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

HEATH_CHECK=$(aws elb describe-instance-health --load-balancer-name $ELB  --instances $NEW_INSTANCE_ID)

until [ `echo $HEATH_CHECK | grep -o "InService"` ]
do
	echo $HEATH_CHECK
	sleep 5
	HEATH_CHECK=$(aws elb describe-instance-health --load-balancer-name $ELB  --instances $NEW_INSTANCE_ID)
done

aws elb deregister-instances-from-load-balancer --load-balancer-name $ELB --instances $OLD_INSTANCE_ID

aws ec2 terminate-instances --instance-ids $OLD_INSTANCE_ID

rm -rf .vagrant

vagrant global-status --prune