locals {
  instance_arch = can(regex("\\w\\dg\\..*", var.instance_type)) ? "arm64" : "x86_64"
}
