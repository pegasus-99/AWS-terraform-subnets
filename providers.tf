# provider "aws" {
#   region = "us-east-2"
# }

provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.14"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.1"
    }
  }
}

