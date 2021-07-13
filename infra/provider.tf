provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.44.0"
    }
  }

  required_version = "~> 1.0.1"
}
