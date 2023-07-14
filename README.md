# Learning-OIDC-with-Terraform-Cloud

This is a bare-bones "How To" for getting this configuration set up (As of 07/2023):

# GitHub Actions -> Terraform Cloud -> [Terraform.io OIDC] -> AWS
Using IaC, Terraform, to deploy purely off of cloud credentials and automate deployment upon change to Terraform.

Long-term credentials:
NO, using ACCESS_KEY and SECRET_KEY as TFC (Teffarform Cloud) Environmental Variables.

Short-term credentials:
YES, using STS (Security Token Service) with an OIDC (Open Identity Provider) as TFC Environmental Variables.
