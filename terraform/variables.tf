variable "aws_region" {
  type        = string
  description = "AWS region to create resources"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.10.10.0/24"
}

variable "ecs_container_count" {
  type        = number
  description = "Number of containers in ECS Web Cluster"
  default     = 2
}

variable "ecs_container_port" {
  type        = number
  description = "Port the ecs web containers will listen on"
  default     = 8500
}

variable "ecs_healthcheck_path" {
  type        = string
  description = "Path the ecs containers will listen for health checks"
  default     = "/status.html"
}

variable "internal_instance_count" {
  type        = number
  description = "Number of internal EC2 instances"
  default     = 1
}

variable "internal_instance_type" {
  type        = string
  description = "Machine type of EC2 internal instance"
  default     = "t3.small"
}

variable "internal_port" {
  type        = number
  description = "Port the internal RL service listens on"
  default     = 8500
}
