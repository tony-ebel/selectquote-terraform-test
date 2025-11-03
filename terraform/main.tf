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
  internal_sg_id      = module.internal.internal_sg_id
  internal_port       = var.internal_port
  internal_dns_record = module.internal.internal_dns_record

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
  web_sg_id           = module.web.web_sg_id
  port                = var.internal_port

  depends_on = [
    module.vpc
  ]
}

# Save ssh private key to local filesystem
resource "local_file" "ssh_private_key_pem" {
  content         = module.internal.ssh_private_key_pem
  filename        = "ssh-private-key.pem"
  file_permission = "0400"
}

module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  web_port          = var.ecs_container_port
  healthcheck_path  = var.ecs_healthcheck_path
  web_sg_id         = module.web.web_sg_id
}
