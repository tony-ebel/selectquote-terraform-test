module "vpc" {
  source = "./modules/vpc"

  cidr = "10.10.10.0/24"
}
