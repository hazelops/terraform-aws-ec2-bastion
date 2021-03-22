output "cmd" {
  value = merge({},{
    up     = "ssh -M -S bastion.sock -fNT ubuntu@${element(aws_instance.this.*.id, 0)} "
    down   = "ssh -S bastion.sock -O exit ubuntu@${element(aws_instance.this.*.id, 0)} "
    status = "ssh -S bastion.sock -O check ubuntu@${element(aws_instance.this.*.id, 0)}"
  })
}

output "instance_id" {
  value = element(aws_instance.this.*.id, 0)
}

output "ssh_config" {
  value = join("", local.ssh_config)
}
output "security_group" {
  value = join("", aws_security_group.this.id)
}
