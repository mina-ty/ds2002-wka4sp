#!/bin/bash

file=$1
bucket=$2
expiration=$3

# copy file to bucket
aws s3 cp "$file" "s3://$bucket/"

# create expiring link
aws s3 presign --expires-in $expiration "s3://$bucket/$file"
