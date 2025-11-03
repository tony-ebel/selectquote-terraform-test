variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr to define sg traffic"
}

variable "ecs_container_count" {
  type        = number
  description = "desired number of conatiners in ECS service"
  default     = 2
}

variable "ecs_container_port" {
  type        = number
  description = "port the containers will listen on"
  default     = 8500
}

variable "rocket_league_image" {
  type        = string
  description = "RL Image for ECS containers to run on"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "public subnet ids for ECS conatainers"
}

variable "alb_sg_id" {
  type        = string
  description = "alb security group id to allow ingress"
}

variable "target_group_arn" {
  type        = string
  description = "alb target group arn for web ecs containers to use"
}

variable "internal_sg_id" {
  type        = string
  description = "internal EC2 security group id to allow egress"
}

variable "internal_port" {
  type        = number
  description = "port the internal rocket league instance listens on"
}

variable "internal_dns_record" {
  type        = string
  description = "dns record to reach internal ec2 instances"
}
