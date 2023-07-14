terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  cloud {
    organization = "my-org"

    workspaces {
    name = "my-app-prod"
    }
   }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "My-Terraform-Cloud-Bucket"
}
