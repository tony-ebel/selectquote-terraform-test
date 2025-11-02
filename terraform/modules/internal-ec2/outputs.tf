output "internal_sg_id" {
  description = "internal EC2 security group id"
  value       = aws_security_group.internal.id
}

output "internal_dns_record" {
  description = "DNS record for internal instances"
  value       = aws_route53_record.internal.name
}
