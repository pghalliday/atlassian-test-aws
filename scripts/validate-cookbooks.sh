#!/bin/bash -e

COOKBOOKS_DIR=$1

for cookbook in $COOKBOOKS_DIR/*
do
  echo "** Validating cookbook: $cookbook"
  echo
  chef exec rubocop $cookbook
  chef exec foodcritic --epic-fail any $cookbook
  echo
  echo
done

chef exec rspec
