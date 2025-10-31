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
  ecs_container_port  = var.ecs_container_port
  rocket_league_image = "${aws_ecr_repository.rocket_league_web.repository_url}:latest"
  alb_sg_id           = module.alb.alb_sg_id
  target_group_arn    = module.alb.target_group_arn
  internal_sg_id      = module.internal.internal_sg_id
  internal_port       = var.internal_port

  depends_on = [
    module.vpc
  ]
}

module "internal" {
  source = "./modules/internal-ec2"

  vpc_id              = module.vpc.vpc_id
  vpc_cidr            = var.vpc_cidr
  private_subnet_id   = module.vpc.private_subnet_id
  instance_count      = var.internal_instance_count
  instance_type       = var.internal_instance_type
  rocket_league_image = "${aws_ecr_repository.rocket_league_internal.repository_url}:latest"
  ssh_public_key      = var.ssh_public_key
  web_sg_id           = module.web.web_sg_id
  port                = var.internal_port

  depends_on = [
    module.vpc
  ]
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  web_port          = var.ecs_container_port
  health_check_path = var.ecs_health_check_path
  web_sg_id         = module.web.web_sg_id
}
