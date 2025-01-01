variable "env" {
  type        = string
  description = "Environment name, for example `dev`"
}

variable "name" {
  type        = string
  description = "Name of the bastion host"
  default     = "bastion"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the bastion host will be created"
}

variable "public_subnets" {
  type        = list(string)
  description = "Public subnets (if set, private subnets are ignored)"
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "Private subnets"
}

variable "ec2_key_pair_name" {
  type        = string
  description = "EC2 Key Pair Name that the bastion host would be created with"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for bastion host"
  default     = "t4g.nano"
}

variable "instance_ami" {
  type        = string
  description = "AMI ID override for the bastion host. Keep in mind, this module config is targeting Amazon Linux 2023)"
  default     = ""
}

variable "security_groups" {
  type        = list(any)
  description = "Additional security groups to add to bastion host"
  default     = []
}

variable "manage_security_group" {
  type        = bool
  description = "Whether to manage the security group for the bastion host"
  default     = true
}

variable "manage_iam_instance_profile" {
  type        = bool
  description = "Whether to manage the IAM role for the bastion host"
  default     = true
}

variable "ssm_role" {
  type        = string
  description = "SSM role to attach to the bastion host"
  default     = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"

}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the resources"
  default     = {}
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "List of network subnets that are allowed. According to PCI-DSS, CIS AWS and SOC2 providing a default wide-open CIDR is not secure."
}

variable "asg_enabled" {
  type        = bool
  description = "Enable autoscaling group for bastion host. If enabled, the bastion host will be created as an autoscaling group"
  default     = false
}

variable "asg_cpu_core_count" {
  type        = number
  description = "Number of CPU cores to use for autoscaling group"
  default     = 1
}

variable "asg_cpu_threads_per_core" {
  type        = number
  description = "Number of threads per core to use for autoscaling group"
  default     = 1
}

# TODO: This will be working in the next releases
# variable "atun_config" {
#   type = map(string)
#   description = "Atun port forwarding discovery configuration"
#   default = {}
# }
