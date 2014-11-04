#!/bin/sh


echo aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].PublicDnsName'   --output=text

AWS_DNS_NAME=$(aws ec2 describe-instances   --region=ap-southeast-2   --filter "Name=tag:Name,Values=$JOB_NAME-$BUILD_NUMBER"   --query='Reservations[*].Instances[*].PublicDnsName'   --output=text)
echo $AWS_DNS_NAME


VARIABLE3=`cat <<EOF
{"Comment": "CLI Update of route53 resource","Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": "testdpoll.test.dius.com.au","Type": "CNAME","TTL": 300,"ResourceRecords": [{"Value": "$AWS_DNS_NAME"}]}}]}
EOF`

echo $VARIABLE3

echo $VARIABLE3 > $WORKSPACE/change_resource.json

echo aws route53 change-resource-record-sets --hosted-zone-id Z3MBDC08G5UXLE --change-batch file://$WORKSPACE/change_resource.json

OUTPUT=$(aws route53 change-resource-record-sets --hosted-zone-id Z3MBDC08G5UXLE --change-batch file://$WORKSPACE/change_resource.json)

echo $OUTPUT