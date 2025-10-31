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

variable "ecs_container_image" {
  type        = string
  description = "Image for ECS containers to run on"
  default     = "nginx:latest"
}
