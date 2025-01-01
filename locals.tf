locals {
  instance_arch = contains([
    "t4g",
    "m6g",
    "c6g",
    "r6g"
  ], substr(var.instance_type, 0, 3)) ? "arm64" : "x86_64"
}
