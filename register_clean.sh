#!/bin/sh 
set -x

register_clean.shNEW_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

register-instances-with-load-balancer --load-balancer-name testdpoll2 --instances $NEW_INSTANCE_ID

deregister-instances-from-load-balancer --load-balancer-name testdpoll2 --instances $OLD_INSTANCE_ID

rm -rf .vagrant

vagrant global-status --prune