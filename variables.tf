variable "env" {}
variable "vpc_id" {}

variable "zone_id" {
  description = "Route53 Domain Zone ID"
}

variable "public_subnets" {}
variable "ec2_key_pair_name" {}

variable "instance_type" {
  type = string
  default = "t3.nano"
}

variable "name" {
  default = "bastion"
}

variable "security_groups" {
  description = "External security groups to add to bastion host"
  type = list(any)
  default = []
}

variable "ssh_forward_rules" {
  type = list(string)
  description = "Rules that will enable port forwarding. SSH Config syntax"
  default = []
}

variable "allowed_cidr_blocks" {
  type = list(string)
  description = "List of network subnets that are allowed"
  default = [
    "0.0.0.0/0"
  ]
}

locals {
  name = "${var.env}-bastion"
  ssh_config = concat([
    "Host ${aws_route53_record.this.name}",
    "User ubuntu",
    "IdentityFile ~/.ssh/id_rsa",
  ],var.ssh_forward_rules)
}
