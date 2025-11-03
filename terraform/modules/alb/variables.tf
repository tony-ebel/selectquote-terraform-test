variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "public subnet ids for ECS conatainers"
}

variable "web_port" {
  type        = number
  description = "port the web containers will listen on"
}

variable "healthcheck_path" {
  type        = string
  description = "path the web containers will listen for health checks"
}

variable "web_sg_id" {
  type        = string
  description = "internal EC2 security group id to allow egress"
}
