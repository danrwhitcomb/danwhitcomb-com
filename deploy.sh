#!/bin/bash

hugo -D
aws s3 sync ./public s3://danwhitcomb-com --acl public-read --delete --cache-control max-age=43200

aws cloudfront create-invalidation --distribution-id E2MR3EZL7U5COV --paths "/*"
