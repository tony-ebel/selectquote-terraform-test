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

variable "ecs_container_image" {
  type        = string
  description = "Image for ECS containers to run on"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "public subnet ids for ECS conatainers"
}

variable "internal_sg_id" {
  type        = string
  description = "internal EC2 security group id to allow egress"
}
