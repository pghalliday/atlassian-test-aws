#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

templates_dir=$DIR/templates

for template in $templates_dir/*
do
  echo "** Validating template: $template"
  echo
  aws cloudformation validate-template --profile atlassian-test --template-body file://$template
  echo
  echo
done
