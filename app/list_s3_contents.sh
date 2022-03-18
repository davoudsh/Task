#!/bin/bash

echo "contents-type: text/plain"
echo ""

# The command to get the helm charts in helmrepo-bucket
command=`AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3api list-objects --bucket helmrepo-bucket --output json`

echo "Here is the contents of helmrepo-bucket:"
echo "$command"
