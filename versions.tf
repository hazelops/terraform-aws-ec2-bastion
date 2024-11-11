terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      version = ">= 4"
      source  = "hashicorp/aws"
    }
  }
}
