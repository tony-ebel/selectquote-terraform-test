output "web_ecs_sg_id" {
  description = "web ECS security group id"
  value       = aws_security_group.web.id
}
