output "internal_sg_id" {
  description = "internal EC2 security group id"
  value       = aws_security_group.internal.id
}

output "internal_dns_record" {
  description = "DNS record for internal instances"
  value       = aws_route53_record.internal.name
}

output "ssh_private_key_pem" {
  description = "private ssh key to connect to instances"
  value       = tls_private_key.main.private_key_pem
}

output "internal_instance_ids" {
  description = "internal instance ids used for deploys"
  value       = join(" ", aws_instance.internal[*].id)
}
