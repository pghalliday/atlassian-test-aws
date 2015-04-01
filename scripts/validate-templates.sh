#!/bin/bash -e

TEMPLATES_DIR=$1

for template in $TEMPLATES_DIR/*
do
  echo "** Validating template: $template"
  echo
  aws cloudformation validate-template --profile atlassian-test --template-body file://$template
  echo
  echo
done
