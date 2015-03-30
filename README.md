# atlassian-test

## Prerequisites

- Create an `atlassian-test` IAM user with the following user policy

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
        }
    ]
}
```

- TODO: add parameters for hosted zone and document hosted zone prerequisite
- [AWS CLI tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Configure an AWS profile with the keys from the `atlassian-test` user created above and set the default region to `us-east-1` and the default output format to `text`

```
aws configure --profile atlassian-test
```

## Usage

To create the stack, from the project directory

```
aws cloudformation create-stack --profile atlassian-test --stack-name atlassian-test --template-body file://atlassian-test.template
```

To update the stack, from the project directory

```
aws cloudformation update-stack --profile atlassian-test --stack-name atlassian-test --template-body file://atlassian-test.template
```

To delete the stack

```
aws cloudformation delete-stack --profile atlassian-test --stack-name atlassian-test
```
