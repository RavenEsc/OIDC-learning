# Learning-OIDC-with-Terraform-Cloud

This is a "How To" for getting this configuration set up (As of 07/2023):
(With linked images)

# GitHub Actions &#8594; [GitHub OAuth] &#8594; Terraform Cloud &#8594; [Terraform.io OIDC] &#8594; AWS
Using IaC, Terraform, to deploy purely off of cloud credentials and automate deployment upon change to Terraform code.

Long-term credentials:
NO, using ACCESS_KEY and SECRET_KEY as TFC (Terraform Cloud) Environmental Variables.

Short-term credentials:
YES, using STS (Security Token Service) with an OIDC (Open Identity Provider) as TFC Environmental Variables.

What is involved? What is needed?

- GitHub (Actions), A GitHub Account
- Terraform ('.tf', TFC, and OIDC), A Terraform Cloud Account
- AWS (IAM roles, Trust Policies, & IDP, and S3), An AWS Account

# ***Console***

## How to set up a SECURE Terraform Automatic Deployment

### 1. IAM-IDP (AWS)

- [ ] Proceed to ' IAM '
- [ ] Click on ' Identity Providers '
- [ ] Then on ' Add Provider '

[ IAM/Identity_Provider ](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-2#/identity_providers)
  > ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/30729f19-fc53-4574-921f-89b331eebe81)


### 2. Add Provider (AWS)

From there:
- [ ] Click on the 'OpenID Connect' option
- [ ] In the 'Provider URL' type ```https://app.terraform.io```
- [ ] Click on the 'Get Thumbprint' button
- [ ] In the 'Audience' field, type ```aws.workload.identity```
- [ ] Finish creating the IDP link by clicking on 'Add Provider'

[ Terraform OpenIDC ](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-2#/identity_providers/create)
  > ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/4547f13e-2d29-4ce4-8dbc-e186de03c98e)

### 3. Assign IAM-Role (AWS)

After it sends you back to the Identity Provider page:
- [ ] Click on your new Provider in the list below: 'app.terraform.io'
- [ ] Then, on the new page, click on the 'Assign Role' button
- [ ] At the pop-up, select 'Create New Role', then click 'Next'

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/87e1326a-9f07-415d-a6cb-d14b402e76e1)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/dc704f2e-3656-42c8-a5c4-5f3522cc85df)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/676a7e8d-9474-4e72-8fb5-9cd0210d719b)


### 4. Create Role (AWS)

The Type and IDP should be pre-selected,
- [ ] So, click on the 'Audience' field and select the 'aws.workload.identity' option from Step 2
- [ ] After which, click 'Next:Permission'
  
- [ ] Then, click on the box for the 'AdministratorAccess' role
- [ ] Followed then by selecting 'Next:Tags

- [ ] Skip the next step by clicking 'Next:Review'

- [ ] Name the Role [```TFCAssumeRole```] (You Can Add a Description like "Used for Automatic Service Deployments of Terraform Code.")
- [ ] Then click 'Create Role'

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/ca8758fa-088b-46d7-b1c8-a213c649aeb0)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/6b5d08ef-a56d-4694-8a41-c9fa582bdbe0)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/5ecbfa64-2046-44e0-9901-67ea5b768df4)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/a2ba37e2-45ae-4457-9928-c504f8842e2d)


### 5. Connect to Terraform Cloud (TFC)

Finish Up on AWS by typing 'TFC' in the search bar to find TFCAssumeRole.
- [ ] Then, click on your role and proceed to the TFCAssumeRole menu
- [ ] In the top right, there is an ARN. Click on the 'Copy' button and save for a later step

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/74f74f2b-505a-4743-b5d3-93daa03fb55a)

Go into your Terraform Cloud Account and...
- [ ] At the bottom left click 'Create New Organization'
  - [ ] Name it ```[your_name]-personal-org```
  - [ ] Given it your email and select 'Create Organization'
  - [ ] Go into your new Organization on the bottom left

- [ ] Create a Project, go under 'Manage' on the left, 'Projects and Workspaces'. Select 'New' on the top right, followed by 'Project'
  - [ ] Name it ```GitHub-to-AWS```

- [ ] Create a Workspace, go under 'Manage' on the left, 'Projects and Workspaces'. Select 'New' on the top right, followed by 'Workspace'
  - [ ] Select 'API-Driven Workflow'
  - [ ] Name it ```Learning-GitHubActions-Terraform```
  - [ ] Click on the 'Project' field, and select 'GitHub-to-AWS'
  - [ ] Then Select 'Create Workspace'

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/41eddc8b-8c6e-4f68-b325-305ef552778e)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/26600d5d-9919-47e9-a68a-424ba95b0f29)

- [ ] Afterwards, navigate under 'Manage' on the left, 'Settings'. Next, under 'Organization Settings', select 'Variable Sets' and select 'Create Variable Set'
- [ ] Name it ```AWSAssumeRoleVariableSet```, then under 'Variable Set Scope', select 'Apply to specific projects and workspaces'
- [ ] Under 'Apply to projects', Select 'GitHub-to-AWS'
- [ ] Under 'Apply to workspaces', Select 'Learning-GitHubActions-Terraform'
  - [ ] Under 'Variables', Select 'Add Variable'. Select 'Add Variable'
  - [ ] Then, Select 'Environmental Variable' and type in the 'Key' field: ```TFC_AWS_PROVIDER_AUTH```, then in the 'Value' field: ```True```
  - [ ] Under 'Variables', Select 'Add Variable'. Select 'Add Variable'
  - [ ] Then, Select 'Environmental Variable' and type in the 'Key' field: ```TFC_AWS_RUN_ROLE_ARN```, then in the 'Value' field: ```[your TFCAssumeRole ARN copied earlier]```. Select 'Add Variable'
- [ ] Finally, click 'Create Variable Set'

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/4b744c6f-c5fc-47f8-9351-d07165d75b48)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/0d49863a-f22d-4aeb-8d82-3e9df35dcea3)

> ![image](https://github.com/RavenEsc/OIDC-learning/assets/107158921/a2ee3abd-6b95-4812-bfcd-6ff0330522f3)

### 6. GitHub Repository (Git)

- [ ] 
- [ ] 

### 7. Create Workflow and Terraform Files (Git)

- [ ] 
- [ ] 

### 8. Link GitHub Actions to Terraform Cloud; GitHub OAuth (Git &#8594; TFC)

- [ ] Go into Terraform Cloud, under 'User Settings' select 'Tokens'
- [ ] Scroll down to 'GitHub App OAuth Token' and select the button and follow the steps to link your GitHub Account to your TFC Account

  ### 9. TEST Test Connection (Git &#8594; TFC &#8594; AWS)

- [ ] 
- [ ] 

### 10. DEBUG Test Connection (TFC &#8594; AWS)
- [ ] In your Command Line Interface (CLI), create a new folder enter it, afterward enter ```terraform login```, enter ```yes```, then Select 'Generate Token'
- [ ] _Copy the token and then paste it into the input field open on your Command Line_ (This may take a few tries since you can not see what you paste, remember, "copy, then select the field in the CLI, and paste with [ctrl + v or cmd + v]") - TIP - Instead of generating a new token every try, copy the old token into the new attempted login on the CLI and it should work as intended without cluttering up your API Tokens
- [ ] Then, create a file in the current folder called ```test-tfc.tf```, in the file enter this code:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "[[[your_name]-personal-org]]"

    workspaces {
    name = "Learning-GitHubActions-Terraform"
    }
   }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "[your_name]-terraform-cloud-bucket[random_number]"
}
```
- [ ] Then, save and return to the folder in the CLI and perform ```terraform init``` then ```terraform plan```
- [ ] As it is planning, go to the Terraform Cloud Workspace 'Learning-GitHubActions-Terraform' and check under the 'Runs' on the left and it should give you any error messages to debug inside 'Triggered via CLI', if it says planned and finished, then the connection is good to go and your permissions and credentials are in order!

## Any Questions?
> - **DOUBLE CHECK NAMING SYNTAX**, my first time I set step 5, "TFC_AWS_PROVIDER_AUTH" was "TFC_AWS_PROVIDER_**UA**TH"
> - Compare Example Files with Yours
> - Open an 'Issue' in the top left of the repository and I will try to get to it

### References:
Setting up the Terraform Cloud to AWS OIDC connection (Steps 1-5) from Jorge Pablos
- https://labinhood.com/blog/2023/02/terraform-cloud-and-aws-via-openid-connect-oidc/
- https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#configure-aws
