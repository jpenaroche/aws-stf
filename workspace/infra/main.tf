locals {
  state_bucket = "segments-${var.enviromment}-tf-state"
}

terraform {
  backend "s3" {
    bucket         = local.state_bucket
    key            = "terraform.tfstate"
    region         = var.region
    dynamodb_table = "segments-${var.enviromment}-terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

module "app" {
  source      = "./app"
  environment = var.enviromment
  region      = var.region
}
