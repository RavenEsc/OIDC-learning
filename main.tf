terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  cloud {
    remote_state {
      organization = "raven-for-aws"

      workspaces {
        name = "OIDC-test-configuration"
      }
    }
   }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::464004139021:role/TerraformCloudassumerole"
  }
}

resource "aws_s3_bucket" "this" {
  bucket = "My-Terraform-Cloud-Bucket"
}
