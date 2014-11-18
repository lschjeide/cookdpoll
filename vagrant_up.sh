#!/bin/sh 
set -x

NEW_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

until [ -n "$NEW_INSTANCE_ID" ]
do

ELB_HOSTNAME=$(aws elb create-load-balancer --load-balancer-name $ELB --listeners Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=8080 --availability-zones ap-southeast-2b --security-groups sg-b5ce00d0)

VARIABLE3=`cat <<EOF
{"Comment": "CLI Create route53 resource","Changes": [{"Action": "CREATE","ResourceRecordSet": {"Name": "$DNSNAME.test.dius.com.au","Type": "CNAME","TTL": 300,"ResourceRecords": [{"Value": "$ELB_HOSTNAME"}]}}]}
EOF`

echo $VARIABLE3 > $WORKSPACE/change_resource.json

aws route53 change-resource-record-sets --hosted-zone-id Z3MBDC08G5UXLE --change-batch file://$WORKSPACE/change_resource.json

OLD_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Live,Values=$LIVEVAL"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

aws ec2 create-tags --resources $OLD_INSTANCE_ID --tags Key=Live,Value=$DEADVAL

VAGRANT_LOG=debug AWSNAME=${JOB_NAME}-${BUILD_NUMBER} vagrant up --provider=aws

NEW_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

if [ -n "$NEW_INSTANCE_ID" ]
then
    echo "NEW INSTANCE DOES NOT EXIST -- VAGRANT UP FAILED! TRY AGAIN...."
    rm -rf .vagrant
    vagrant global-status --prune
fi

done