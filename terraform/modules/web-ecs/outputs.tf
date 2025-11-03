output "web_sg_id" {
  description = "web ECS security group id"
  value       = aws_security_group.web.id
}

output "ecs_cluster_name" {
  description = "ecs cluster name output for deployments"
  value       = aws_ecs_cluster.web.name
}

output "ecs_service_name" {
  description = "ecs service name output for deployments"
  value       = aws_ecs_service.web.name
}
