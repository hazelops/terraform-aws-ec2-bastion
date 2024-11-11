output "security_group" {
  value       = aws_security_group.this[0].id
  description = "The ID of the security group"
}

output "tags" {
  value       = var.tags
  description = "The tags for the bastion host"
}
