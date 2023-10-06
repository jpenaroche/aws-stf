#!/bin/bash

# JSON object to pass to Lambda Function
# json={"\"campaignIds\"":[1,2,3]}
json={"\"msg\"":"\"ServerlessComputingWithFaaS\",\"shift\"":22}
smarn=$1
exearn=$(
  awslocal stepfunctions start-execution --state-machine-arn $smarn --input $json | jq -r ".executionArn"
)
#poll output
output="RUNNING"
while [ "$output" == "RUNNING" ]; do
  echo "Status check call..."
  alloutput=$(awslocal stepfunctions describe-execution --execution-arn $exearn)
  output=$(echo $alloutput | jq -r ".status")
  echo "Status check=$output"
done
echo ""
awslocal stepfunctions describe-execution --execution-arn $exearn | jq -r ".output" | jq
