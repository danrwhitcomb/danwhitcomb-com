#!/bin/bash

hugo -D
aws s3 sync ./public s3://danwhitcomb-com --acl public-read
