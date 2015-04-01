# atlassian-test

## Prerequisites

- [AWS CLI tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Create an S3 bucket to hold the template and cookbooks - `$AT_BUCKET_NAME`
- Create an EC2 key pair to associate with instances - `$AT_KEY_PAIR`
- Create an IAM user with the following user policy (substitute `$AT_BUCKET_NAME`)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1427745676000",
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1427745694000",
            "Effect": "Allow",
            "Action": [
                "cloudformation:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1427745715000",
            "Effect": "Allow",
            "Action": [
                "route53:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "Stmt1427745716000",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::$AT_BUCKET_NAME"
            ]
        },
        {
            "Sid": "Stmt1427745717000",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::$AT_BUCKET_NAME/*"
            ]
        },
        {
            "Sid": "Stmt1427802739000",
            "Effect": "Allow",
            "Action": [
                "iam:*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

- Add a Route53 hosted zone - `$AT_HOSTED_ZONE`
- Configure an AWS profile with the keys from the IAM user created above and set your default region (eg. `us-east-1`) and the default output format to `text`

```
aws configure --profile atlassian-test
```

- Choose a first availability zone in your default region (eg. `us-east-1b`) - `$AT_AVAILABILITY_ZONE_1`

## Usage

To validate the templates

```
./validate-templates.sh
```

To sync the template and cookbooks to the S3 bucket (substitute `$AT_BUCKET_NAME`)

```
./sync-s3.sh $AT_BUCKET_NAME
```

To create the stack, from the project directory (substitute `$AT_KEY_PAIR`, `$AT_BUCKET_NAME`, `$AT_HOSTED_ZONE` and `$AT_AVAILABILITY_ZONE_1`)

```
aws cloudformation create-stack \
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
```

To update the stack, from the project directory (substitute `$AT_KEY_PAIR`, `$AT_BUCKET_NAME`, `$AT_HOSTED_ZONE` and `$AT_AVAILABILITY_ZONE_1`)

```
aws cloudformation update-stack \
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
```

To delete the stack

```
aws cloudformation delete-stack \
--profile atlassian-test \
--stack-name atlassian-test
```

## Hint

Copy `example.parameters.sh` to `parameters.sh` and set your parameters in there. Then you can source `parameters.sh` and run the above commands without substitution.

```
cp example.parameters.sh parameters.sh
vim parameters.sh
source ./parameters.sh
```
