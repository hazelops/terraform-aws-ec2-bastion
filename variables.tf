variable "env" {
  type = string
  description = "Environment name, for example `dev`"
}

variable "aws_profile" {
  type = string
  description = "AWS Profile to use during tunnel creation"
}

variable "vpc_id" {
    type = string
    description = "VPC ID"
}

variable "private_subnets" {
    type = list(string)
    description = "Private subnets"
}

variable "ec2_key_pair_name" {
    type = string
    description = "EC2 Key Pair Name"
}

variable "instance_type" {
  type    = string
  description = "EC2 instance type for bastion host"
  default = "t3.nano"
}

variable "name" {
  default = "bastion"
}

variable "ext_security_groups" {
  description = "External security groups to add to bastion host"
  type        = list(any)
  default     = []
}

variable "ssm_role" {
  type    = string
  default = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the resources"
  default = {}
}

variable "ssh_forward_rules" {
  type        = list(string)
  description = "Rules that will enable port forwarding. SSH Config syntax"
  default     = []
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of network subnets that are allowed. According to PCI-DSS, CIS AWS and SOC2 providing a default wide-open CIDR is not secure."
}

locals {
  name         = "${var.env}-bastion"
  proxycommand = <<-EOT
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    EOT
  ssh_config   = concat([
    "# SSH over Session Manager",
    "host i-* mi-*",
    "ServerAliveInterval 180",
    local.proxycommand,
  ], var.ssh_forward_rules)
  ssm_document_name = local.name
}
