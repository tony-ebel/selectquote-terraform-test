output "ecs_cluster_name" {
  description = "ecs cluster name output for deployments"
  value       = module.web.ecs_cluster_name
}

output "ecs_service_name" {
  description = "ecs service name output for deployments"
  value       = module.web.ecs_service_name
}
