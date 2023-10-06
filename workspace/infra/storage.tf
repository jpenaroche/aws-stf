resource "aws_s3_bucket" "terraform_state" {
  bucket        = local.state_bucket
  force_destroy = true
}
