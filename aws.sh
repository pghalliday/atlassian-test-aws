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
  $DIR/scripts/sync-s3.sh $AT_BUCKET_NAME $DIR/templates $DIR/build

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
    "ParameterKey": "backupBucketName",
    "ParameterValue": "'$AT_BACKUP_BUCKET_NAME'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "domain",
    "ParameterValue": "'$AT_DOMAIN'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "dbUsername",
    "ParameterValue": "'$AT_DB_USERNAME'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "dbPassword",
    "ParameterValue": "'$AT_DB_PASSWORD'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "availabilityZone1",
    "ParameterValue": "'$AT_AVAILABILITY_ZONE_1'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "availabilityZone2",
    "ParameterValue": "'$AT_AVAILABILITY_ZONE_2'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "gmailUsername",
    "ParameterValue": "'$AT_GMAIL_USERNAME'",
    "UsePreviousValue": false
  }, {
    "ParameterKey": "gmailPassword",
    "ParameterValue": "'$AT_GMAIL_PASSWORD'",
    "UsePreviousValue": false
  }]'
fi
