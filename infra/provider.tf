provider "aws" {
  region = "us-east-1"
  shared_credentials_file = "~/.aws/credentials"
}
terraform {
  backend "s3" {
    bucket  = "${var.bucket}"
    key     = "${var.terraform_key}"
    region  = "${var.aws_region}"
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
