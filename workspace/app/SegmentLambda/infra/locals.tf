locals {
  lambda_name = "segment-creation"
  tags = {
    created_by = "Terraform"
    region     = var.region
  }
}
