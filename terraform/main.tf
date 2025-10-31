module "vpc" {
  source = "./modules/vpc"

  cidr = var.vpc_cidr
}

module "web" {
  source = "./modules/web-ecs"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  public_subnet_ids   = module.vpc.public_subnet_ids
  ecs_container_count = var.ecs_container_count
  ecs_container_image = var.ecs_container_image

  depends_on = [
    module.vpc
  ]
}
