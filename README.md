# atlassian-test

## Prerequisites

- [AWS CLI tools](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- Create an S3 bucket to hold the template and cookbooks - `$AT_BUCKET_NAME`
- Create an S3 bucket to hold  base and home folder backups for the services- `$AT_BACKUP_BUCKET_NAME`
- Create an EC2 key pair to associate with instances - `$AT_KEY_PAIR`
- Create an IAM user with full administrator permissions
- Choose a user name and password for the master database user - `$AT_DB_USERNAME`, `$AT_DB_PASSWORD` (the password must be at least 8 characters)
- Add a Route53 hosted zone - `$AT_DOMAIN` (don't use the trailing dot in `parameters.sh`)
- Configure an AWS profile with the keys from the IAM user created above, setting your default region (eg. `us-east-1`) and the default output format to `text`

```
aws configure --profile atlassian-test
```

- Choose a first availability zone in your default region (eg. `us-east-1b`) - `$AT_AVAILABILITY_ZONE_1`
- Choose a second availability zone in your default region (eg. `us-east-1c`, the RDS instance requires 2 availability zones) - `$AT_AVAILABILITY_ZONE_2`
- Copy `example.parameters.sh` to `parameters.sh` and set your parameters in there.

```
cp example.parameters.sh parameters.sh
vim parameters.sh
```

- Create a Gmail account to use for SMTP - `$AT_GMAIL_USERNAME`, `$AT_GMAIL_PASSWORD`

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
