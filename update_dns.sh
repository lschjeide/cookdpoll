#!/bin/sh 
set -x


OLD_INSTANCE_ID=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Live,Values=true"   --query='Reservations[*].Instances[*].InstanceId'   --output=text)

VAGRANT_LOG=debug AWSNAME=${JOB_NAME}-${BUILD_NUMBER} vagrant up --provider=aws


AWS_DNS_NAME=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].PublicDnsName'   --output=text)


VARIABLE3=`cat <<EOF
{"Comment": "CLI Update of route53 resource","Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": "$DNSNAME.test.dius.com.au","Type": "CNAME","TTL": 300,"ResourceRecords": [{"Value": "$AWS_DNS_NAME"}]}}]}
EOF`

echo $VARIABLE3 > $WORKSPACE/change_resource.json

OUTPUT=$(aws route53 change-resource-record-sets --hosted-zone-id Z3MBDC08G5UXLE --change-batch file://$WORKSPACE/change_resource.json)

aws ec2 terminate-instances --instance-ids $OLD_INSTANCE_ID

rm -rf .vagrant

vagrant global-status --prune