terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "raven-for-aws"

    workspaces {
    name = "OIDC-test-configuration"
    }
   }
}

# Configure the AWS Provider 2
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "ravens-terraform-cloud-bucket1"
}
