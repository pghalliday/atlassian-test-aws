#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ "$1" = "delete" ]
then
  aws cloudformation delete-stack \
  --profile atlassian-test \
  --stack-name atlassian-test
else
  COMMAND="update-stack"
  if [ "$1" = "create" ]
  then
    COMMAND="create-stack"
  fi

  source $DIR/parameters.sh
  $DIR/scripts/sync-s3.sh $AT_BUCKET_NAME

  aws cloudformation $COMMAND \
  --profile atlassian-test \
  --stack-name atlassian-test \
  --capabilities CAPABILITY_IAM \
  --template-url https://s3.amazonaws.com/$AT_BUCKET_NAME/templates/all.json \
  --parameters '[{
    "ParameterKey": "keyName",
    "ParameterValue": "'$AT_KEY_PAIR'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "bucketName",
    "ParameterValue": "'$AT_BUCKET_NAME'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "hostedZoneName",
    "ParameterValue": "'$AT_HOSTED_ZONE'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "availabilityZone1",
    "ParameterValue": "'$AT_AVAILABILITY_ZONE_1'",
    "UsePreviousValue": false
  }]'
fi
