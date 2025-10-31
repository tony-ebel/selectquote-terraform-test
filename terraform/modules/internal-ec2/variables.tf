variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "vpc_cidr" {
  type        = string
  description = "vpc cidr to define sg traffic"
}

variable "private_subnet_id" {
  type        = string
  description = "private subnet id for EC2 instances"
}

variable "instance_count" {
  type        = number
  description = "number of EC2 internal instances"
}

variable "instance_type" {
  type        = string
  description = "instance type to use for EC2 instances"
}

variable "rocket_league_image" {
  type        = string
  description = "ecr rocket league internal image"
}

variable "ssh_public_key" {
  type        = string
  description = "ssh public key used to connect to EC2 instance as core user"
}

variable "web_sg_id" {
  type        = string
  description = "web security group id to allow ingress between ECS and EC2"
}
