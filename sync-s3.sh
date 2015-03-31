#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

instances_dir=$DIR/instances
s3_dir=$DIR/s3

rm -rf $s3_dir
mkdir -p $s3_dir

cp atlassian-test.template $s3_dir

for dir in $instances_dir/*/
do
  cd $dir
  rm -f *.tar.gz
  berks package
  mv cookbooks-*.tar.gz $s3_dir/$(basename $dir).tar.gz
done

aws s3 sync --profile atlassian-test --delete $s3_dir s3://atlassian.pghalliday.net
