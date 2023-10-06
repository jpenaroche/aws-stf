#!/bin/bash

awslocal logs describe-log-streams --log-group-name $1 --query 'logStreams[*].logStreamName' --output table | awk '{print $2}' | grep -v ^$ | while read x; do awslocal logs delete-log-stream --log-group-name $1 --log-stream-name $x; done
