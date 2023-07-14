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

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"

  assume_role {
    role_arn = "arn:aws:iam::464004139021:role/TerraformCloudassumerole"
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "My-Terraform-Cloud-Bucket"
}
