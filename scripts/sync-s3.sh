#!/bin/bash -e

BUCKET_NAME=$1
TEMPLATES_DIR=$2
BUILD_DIR=$3
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

$DIR/validate-templates.sh $TEMPLATES_DIR

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR

cp -r $TEMPLATES_DIR $BUILD_DIR

rm -f *.tar.gz
berks package
mv cookbooks-*.tar.gz $BUILD_DIR/cookbooks.tar.gz

aws s3 sync --profile atlassian-test --delete $BUILD_DIR s3://$BUCKET_NAME
