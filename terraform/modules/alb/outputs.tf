output "alb_sg_id" {
  description = "alb security group id"
  value       = aws_security_group.alb_web.id
}

output "target_group_arn" {
  description = "alb target group arn for web instances to use"
  value       = aws_lb_target_group.tg_web.arn
}
