# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.16"
#     }
#   }
# }

module "combination_lambda_module" {
  source = "../CombinationLambda/infra"

  # vault_address = "http://localhost"
}

module "query_lambda_module" {
  source = "../QueryLambda/infra"

  # vault_address = "http://localhost"
}

module "segment_lambda_module" {
  source = "../SegmentLambda/infra"

  # vault_address = "http://localhost"
}

resource "aws_iam_role" "iam_for_sfn" {
  name               = "${local.stf_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_cloudwatch_log_group" "stf" {
  name              = "/aws/stf/${local.stf_name}"
  retention_in_days = 14
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = local.stf_name
  role_arn = aws_iam_role.iam_for_sfn.arn
  type     = "EXPRESS"

  definition = <<EOF
  {
  "Comment": "A description of my state machine with a hello world example",
  "StartAt": "Process Campaign Audience Segment Request",
  "States": {
    "Process Campaign Audience Segment Request": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "FunctionName": "${module.combination_lambda_module.combination_lambda_arn}",
        "Payload.$": "$"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "Distributed BQ queries"
    },
    "Distributed BQ queries": {
      "Type": "Map",
      "Iterator": {
        "StartAt": "Execute and process BQ queries",
        "States": {
          "Execute and process BQ queries": {
            "Type": "Task",
            "Resource": "arn:aws:states:::lambda:invoke",
            "OutputPath": "$.Payload",
            "Parameters": {
              "Payload.$": "$",
              "FunctionName": "${module.query_lambda_module.query_lambda_arn}"
            },
            "Retry": [
              {
                "ErrorEquals": [
                  "Lambda.ServiceException",
                  "Lambda.AWSLambdaException",
                  "Lambda.SdkClientException",
                  "Lambda.TooManyRequestsException"
                ],
                "IntervalSeconds": 1,
                "MaxAttempts": 3,
                "BackoffRate": 2
              }
            ],
            "End": true
          }
        }
      },
      "MaxConcurrency": 1000,
      "Next": "Finalize Campaign Audience Segment Creation"
    },
    "Finalize Campaign Audience Segment Creation": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "OutputPath": "$.Payload",
      "Parameters": {
        "Payload.$": "$",
        "FunctionName": "${module.segment_lambda_module.segment_lambda_arn}"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "End": true
    }
  }
}
EOF

  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.stf.arn}:*"
    include_execution_data = true
    level                  = "ERROR"
  }

  depends_on = [module.combination_lambda_module, module.query_lambda_module, module.segment_lambda_module]
}
