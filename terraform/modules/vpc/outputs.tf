output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "public subnet ids"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_id" {
  description = "private subnet id"
  value       = aws_subnet.private_subnet.id
}
