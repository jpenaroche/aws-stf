data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../build"
  output_path = "${local.lambda_name}.zip"
  depends_on  = [null_resource.dependencies]
}

# data "vault_aws_access_credentials" "aws" {
#   backend = "aws"
#   role    = "deployment-role"
#   type    = "sts"
# }
