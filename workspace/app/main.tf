module "campaign-segments" {
  source = "./StepFunction"

  enviromment = var.enviromment
  region      = var.region
}
