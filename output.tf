output "cmd" {
  value = {
    up = "ssh -M -S bastion.sock -fNT ubuntu@${aws_route53_record.this.name}"
    down = "ssh -S bastion.sock -O exit ubuntu@${aws_route53_record.this.name}"
    status = "ssh -S bastion.sock -O check ubuntu@${aws_route53_record.this.name}"
  }
}

output "ssh_config" {
  value = local.ssh_config
}
output "security_group" {
  value = aws_security_group.this.id
}
