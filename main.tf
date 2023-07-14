terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider 4
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "My-Terraform-Cloud-Bucket"
}
