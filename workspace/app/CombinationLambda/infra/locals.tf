locals {
  lambda_name = "segment-combination"
  tags = {
    created_by = "Terraform"
    region     = var.region
  }
}
