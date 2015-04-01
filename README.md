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

- Copy `example.parameters.sh` to `parameters.sh` and set your parameters in there.

```
cp example.parameters.sh parameters.sh
vim parameters.sh
```

## Usage

To create the stack (will validate the templates and upload everything to S3 first)

```
./aws.sh create
```

To update the stack (will validate the templates and upload everything to S3 first)

```
./aws.sh
```

To delete the stack

```
./aws.sh delete
```
