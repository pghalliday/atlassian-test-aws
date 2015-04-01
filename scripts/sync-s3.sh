#!/bin/bash -e

BUCKET_NAME=$1
INSTANCES_DIR=$2
TEMPLATES_DIR=$3
BUILD_DIR=$4
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

$DIR/validate-templates.sh $TEMPLATES_DIR

rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR/cookbooks

cp -r $TEMPLATES_DIR $BUILD_DIR

for dir in $INSTANCES_DIR/*/
do
  cd $dir
  rm -f *.tar.gz
  berks package
  mv cookbooks-*.tar.gz $BUILD_DIR/cookbooks/$(basename $dir).tar.gz
done

aws s3 sync --profile atlassian-test --delete $BUILD_DIR s3://$BUCKET_NAME
