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
berks vendor $BUILD_DIR/cookbooks
( cd $BUILD_DIR/cookbooks && tar -czvf ../cookbooks.tar.gz * )
rm -rf $BUILD_DIR/cookbooks

aws s3 sync --profile atlassian-test --delete $BUILD_DIR s3://$BUCKET_NAME
