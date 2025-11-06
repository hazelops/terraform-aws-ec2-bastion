terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      version = ">= 6"
      source  = "hashicorp/aws"
    }
  }
}
