data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

# data "vault_aws_access_credentials" "aws" {
#   backend = "aws"
#   role    = "deployment-role"
#   type    = "sts"
# }
