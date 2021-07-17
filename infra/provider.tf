provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}
terraform {
  backend "s3" {
    bucket = "gama-academy-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    profile = "default"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.44.0"
    }
  }

  required_version = "~> 1.0.1"
}
