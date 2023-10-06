locals {
  lambda_name = "segment-query"
  tags = {
    created_by = "Terraform"
    region     = var.region
  }
}
