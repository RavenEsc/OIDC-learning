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

# Configure the AWS Provider 7
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "My-Terraform-Cloud-Bucket"
}
