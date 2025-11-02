output "internal_sg_id" {
  description = "internal EC2 security group id"
  value       = aws_security_group.internal.id
}
