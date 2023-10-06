# terraform {
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 4.16"
#     }
#   }
# }

resource "aws_iam_role" "iam_for_lambda" {
  name               = "${local.lambda_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "null_resource" "dependencies" {
  provisioner "local-exec" {
    working_dir = "${path.module}/../"
    command     = "npm i"
  }
}

resource "aws_cloudwatch_log_group" "query_lambda" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 14
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.lambda_name}_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


resource "aws_lambda_function" "query_lambda" {
  function_name    = local.lambda_name
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "${local.lambda_name}.zip"
  handler          = "main.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs16.x"
  timeout          = 30
  tags             = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.query_lambda,
  ]
}

output "query_lambda_arn" {
  value = aws_lambda_function.query_lambda.arn
}
