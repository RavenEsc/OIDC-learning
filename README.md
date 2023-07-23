# Learning-OIDC-with-Terraform-Cloud

This is a "How To" for getting this configuration set up (As of 07/2023):
(With links)

# GitHub Actions &#8594; [GitHub API Tokens] &#8594; Terraform Cloud &#8594; [Terraform.io OIDC] &#8594; AWS
Using IaC, Terraform, to deploy purely off of cloud credentials and automate deployment upon change to Terraform code.

Long-term credentials:
NO, using ACCESS_KEY and SECRET_KEY as TFC (Terraform Cloud) Environmental Variables.

Short-term credentials:
YES, using STS (Security Token Service) with an OIDC (Open Identity Provider) as TFC Environmental Variables.

What is involved? What is needed?

- GitHub (Actions), A GitHub Account
- Terraform ('.tf', TFC, and OIDC), A Terraform Cloud Account
- AWS (IAM roles, Trust Policies, & IDP, and S3), An AWS Account

# How to set up a SECURE Terraform Automatic Deployment on ***Console***

## PART 1: AWS, OIDC, and a Trust Policy

### 1. IAM-IDP

- [ ] Proceed to '**IAM**'
      
- [ ] Click on '**Identity Providers**'
      	([ IAM/Identity_Provider ](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-2#/identity_providers))
      
- [ ] Then on '**Add Provider**'

### 2. Add Provider

From there:
- [ ] Click on the '**OpenID Connect**' option
      
- [ ] In the '**Provider URL**' type ```https://app.terraform.io```
      
- [ ] Click on the '**Get Thumbprint**' button
    
- [ ] In the '**Audience**' field, type ```aws.workload.identity```
      
- [ ] Finish creating the IDP link by clicking on '**Add Provider**'


### 3. Assign IAM-Role

After it sends you back to the Identity Provider page:
- [ ] Click on your new Provider in the list below: '**app.terraform.io**'
      
- [ ] Then, on the new page, click on the '**Assign Role**' button
      
- [ ] At the pop-up, select '**Create New Role**', then click '**Next**'


### 4. Create Role

The Type and IDP should be pre-selected,
- [ ] So, click on the 'Audience' field and select the '**aws.workload.identity**' option from Step 2
      
- [ ] After which, click '**Next:Permission**'
  
- [ ] Then, click on the box for the '**AdministratorAccess**' role
    
- [ ] Followed then by selecting '**Next:Tags**'

- [ ] Skip the next step by clicking '**Next:Review**'

- [ ] Name the Role [```TFCAssumeRole```] (You Can Add a Description like "Used for Automatic Service Deployments of Terraform Code.")
      
- [ ] Then click '**Create Role**'

## PART 2: TFC, Orgs, Projects, Workspaces, and Environmental Variables

### 5. Connect to Terraform Cloud

Finish Up on AWS by typing '**TFC**' in the search bar to find TFCAssumeRole.
- [ ] Then, click on your role and proceed to the TFCAssumeRole menu
    
- [ ] In the top right, there is an ARN. Click on the '**Copy**' button and save for a later step


#### 5a. Create a TFC Organization

Go into your Terraform Cloud Account and...
- [ ] At the bottom left click '**Create New Organization**'

([ TFC Projects/Workspaces ](https://app.terraform.io))

  - [ ] Name it ```[_your_name_]-personal-org``` (Remember, the name needs to be original)
      
  - [ ] Given it your email and select '**Create Organization**'
      
  - [ ] Go into your new Organization on the bottom left


#### 5b. Create a TFC Project

- [ ] Create a Project, go under '**Manage**' on the left, '**Projects and Workspaces**'. Select 'New' on the top right, followed by '**Project**'

- [ ] Name it ```GitHub-to-AWS```


#### 5c. Create a TFC Workspace

- [ ] Create a Workspace, go under '**Manage**' on the left, '**Projects and Workspaces**'. Select '**New**' on the top right, followed by '**Workspace**'

  - [ ] Select '**API-Driven Workflow**'
      
  - [ ] Name it ```Learning-GitHubActions-Terraform```
      
  - [ ] Click on the '**Project**' field, and select '**GitHub-to-AWS**'
      
  - [ ] Then Select '**Create Workspace**'


#### 5d. Setting AWS Role ARN as TFC Environmental Variable

- [ ] Afterwards, navigate under '**Manage**' on the left, '**Settings**'. Next, under '**Organization Settings**', select '**Variable Sets**' and select '**Create Variable Set**'
  
- [ ] Name it ```AWSAssumeRoleVariableSet```, then under '**Variable Set Scope**', select '**Apply to specific projects and workspaces**'
    
- [ ] Under '**Apply to projects**', Select '**GitHub-to-AWS**'
    
- [ ] Under '**Apply to workspaces**', Select '**Learning-GitHubActions-Terraform**'

  - [ ] Under '**Variables**', Select '**Add Variable**'. Select '**Add Variable**'
      
  - [ ] Then, Select '**Environmental Variable**' and type in the '**Key**' field: ```TFC_AWS_PROVIDER_AUTH```, then in the '**Value**' field: ```True```
      
  - [ ] Under '**Variables**', Select '**Add Variable**'. Select '**Add Variable**'
      
  - [ ] Then, Select '**Environmental Variable**' and type in the '**Key**' field: ```TFC_AWS_RUN_ROLE_ARN```, then in the '**Value**' field: ```[_your TFCAssumeRole ARN copied earlier_]```. Select '**Add Variable**'
    
- [ ] Finally, click '**Create Variable Set**'

## PART 3: GitHub, Workflow, Terraform Test File, GitHub API Tokens, and Testing

([ GitHub ](https://github.com/))

### 6. GitHub Repository

Go into your GitHub account and...
- [ ] Click '**Repositories**' on the top left and select '**New**' to create a new repo

- [ ] Name it ```Learning-GitHubActions```, set it as public or private (doesn't matter)

- [ ] Under '**Initialize this directory with**' select/check '**Add a README file**'

- [ ] Click '**Create repository**' on the bottom right


### 7. Create Workflow and Terraform Files (Git)

You can set up your files in GitHub, or any by means (Personal favorite- VSCode, GitHub Desktop, or etc.), but for this set up we will be using GitHub via browser.

#### 7a. Creating a workflow folder

- [ ] Select '**Add File**' Then '**Create New File**'

- [ ] In the file editor, name it ```.github``` then add a ```/``` to create a new folder, then name it ```workflows``` then add a ```/``` to create a new file


#### 7a. Creating workflow files for Terraform Planning and Applying

- [ ] Name the file ```plan-pull.yml``` and then copy this code into it:

(Remember, change the organization to be yours)

```
name: "Terraform Plan"

on:
  pull_request:
  
env:
  TF_CLOUD_ORGANIZATION: "[_your_name_]-personal-org"
  TF_API_TOKEN: "${{ secrets.TF_API_TOKEN }}"
  TF_WORKSPACE: "Learning-GitHubActions-Terraform"
  CONFIG_DIRECTORY: "./"
  
jobs:
  terraform:
    name: "Terraform Plan"
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
      pull-requests: write
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Upload Configuration
      uses: hashicorp/tfc-workflows-github/actions/upload-configuration@v1.0.0
      id: plan-upload
      with:
        workspace: ${{ env.TF_WORKSPACE }}
        directory: ${{ env.CONFIG_DIRECTORY }}
        speculative: true

    - name: Create Plan Run
      uses: hashicorp/tfc-workflows-github/actions/create-run@v1.0.0
      id: plan-run
      with:
        workspace: ${{ env.TF_WORKSPACE }}
        configuration_version: ${{ steps.plan-upload.outputs.configuration_version_id }}
        plan_only: true

    - name: Get Plan Output
      uses: hashicorp/tfc-workflows-github/actions/plan-output@v1.0.0
      id: plan-output
      with:
        plan: ${{ fromJSON(steps.plan-run.outputs.payload).data.relationships.plan.data.id }}

    - name: Update PR
      uses: actions/github-script@v6
      id: plan-comment
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          // 1. Retrieve existing bot comments for the PR
          const { data: comments } = await github.rest.issues.listComments({
            owner: context.repo.owner,
            repo: context.repo.repo,
            issue_number: context.issue.number,
          });
          const botComment = comments.find(comment => {
            return comment.user.type === 'Bot' && comment.body.includes('Terraform Cloud Plan Output')
          });
          const output = `#### Terraform Cloud Plan Output
             \`\`\`
             Plan: ${{ steps.plan-output.outputs.add }} to add, ${{ steps.plan-output.outputs.change }} to change, ${{ steps.plan-output.outputs.destroy }} to destroy.
             \`\`\`
             [Terraform Cloud Plan](${{ steps.plan-run.outputs.run_link }})
             `;
          // 3. Delete previous comment so PR timeline makes sense
          if (botComment) {
            github.rest.issues.deleteComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              comment_id: botComment.id,
            });
          }
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          });
```

- [ ] After that. create a new file and name it ```apply-push.yml``` and then copy this code into it:

(Remember, change the organization to be yours)

```
name: "Terraform Apply"

on:
  push:
    branches:
# Don't Forget to check if the main branch you commit to has "main" as a name. "master" is a common default main branch.
      - main
# Add your org and workspace here. the TF token currently is for the secret variable you add in the repo settings from the generated API token
env:
  TF_CLOUD_ORGANIZATION: "[_your_name_]-personal-org"
  TF_API_TOKEN: "${{ secrets.TF_API_TOKEN }}"
  TF_WORKSPACE: "Learning-GitHubActions-Terraform"
  CONFIG_DIRECTORY: "./"

jobs:
  terraform:
    name: "Terraform Apply"
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Upload Configuration
        uses: hashicorp/tfc-workflows-github/actions/upload-configuration@v1.0.0
        id: apply-upload
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          directory: ${{ env.CONFIG_DIRECTORY }}

      - name: Create Apply Run
        uses: hashicorp/tfc-workflows-github/actions/create-run@v1.0.0
        id: apply-run
        with:
          workspace: ${{ env.TF_WORKSPACE }}
          configuration_version: ${{ steps.apply-upload.outputs.configuration_version_id }}

      - name: Apply
        uses: hashicorp/tfc-workflows-github/actions/apply-run@v1.0.0
        if: fromJSON(steps.apply-run.outputs.payload).data.attributes.actions.IsConfirmable
        id: apply
        with:
          run: ${{ steps.apply-run.outputs.run_id }}
          comment: "Apply Run from GitHub Actions CI ${{ github.sha }}"
```

#### 7c. Creating a Terraform file to test a deployment

- [ ] Leave the '**.github/workflows**' folder and go back to the main directory with the README.txt in the GitHub Repo. Create a new file and name it ```main.tf```
  
- [ ] Then in the file, copy the following test code:

(Remember, the bucket name needs to be original to work and change the organization to be yours)

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "[[[_your_name_]-personal-org]]"

    workspaces {
    name = "Learning-GitHubActions-Terraform"
    }
   }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "[_your_name_]-terraform-cloud-bucket[_random_number_]"
}
```

(The first part of the code links the file to the most up to date version of Hashicorp's terraform AWS provider code, followed by linking the file to your TFC account and workspace. It then sets the provider as AWS in the region 'us-east-1' (it should not matter what region is set). Finally, we set up the S3 bucket to test the permissions of the TFCAssumeRole)


### 8. Link GitHub Actions to Terraform Cloud; GitHub API Tokens ~OAuth~ (Git &#8594; TFC)

- [ ] Go into Terraform Cloud, under '**User Settings**' select '**Tokens**'

([ TFC Tokens ](https://app.terraform.io/app/settings/tokens?utm_source=learn))
    
- [ ] ~Scroll down to '**GitHub App OAuth Token**' and select the button and follow the steps to link your GitHub Account to your TFC Account~ Select '**Generate New Token**' and name it ```GitHub-to-TFC-Token and hit create, then copy the new token and navigate to your GitHub repository, there open '**Settings**' and on the left select '**Secrets and Variables**' then '**Actions**'. Then select '**New Repository Secret**' and name it ```TF_API_TOKEN``` then paste the API token you copied into the value field and hit create!

  ### 9. TEST Test Connection (Git &#8594; TFC &#8594; AWS)

- [ ] Make an edit to the '**main.tf**' file (make a comment using '**//**')

- [ ] Commit the change, but select '**Create a new branch for this commit and start a pull request**' then commit

- [ ] Then, select '**Request Merge**' and wait for the checks to be done. (To see the logs of each step, click on the link that pops up: '**Details**')

If all goes well it, follow the steps it shows, and it should end up saying '**planned and finished**' in your GitHub Pull Request tab, TFC Workspace, and the S3 bucket you made in the terraform file should be in your S3 bucket in the region you put in! If you see errors, be sure to look over the logs in GitHub, or even going to the TFC Worspace will show you the error, then Googling the errors are good ways to debug!


### 10. DEBUG Test Connection (TFC &#8594; AWS)
- [ ] In your Command Line Interface (CLI), create a new folder enter it, afterward enter ```terraform login```, enter ```yes```, then Select '**Generate Token**'
  
- [ ] _Copy the token and then paste it into the input field open on your Command Line_ (This may take a few tries since you can not see what you paste, remember, "copy, then select the field in the CLI, and paste with [ctrl + v or cmd + v]") - TIP - Instead of generating a new token every try, copy the old token into the new attempted login on the CLI and it should work as intended without cluttering up your API Tokens
  
- [ ] Then, create a file in the current folder called ```test-tfc.tf```, in the file enter the following code:

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  cloud {
    organization = "[[[_your_name_]-personal-org]]"

    workspaces {
    name = "Learning-GitHubActions-Terraform"
    }
   }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "this" {
  bucket = "[_your_name_]-terraform-cloud-bucket[_random_number_]"
}
```

(This is the same as your main.tf but in a different directory to avoid cluttering or messing up the GitHub repo when you perform the local 'terraform init' command)

- [ ] Then, save and return to the folder in the CLI and perform ```terraform init``` then ```terraform plan```
    
- [ ] As it is planning, go to the Terraform Cloud Workspace '**Learning-GitHubActions-Terraform**' and check under the 'Runs' on the left and it should give you any error messages to debug inside '**Triggered via CLI**', if it says planned and finished, then the connection is good to go and your permissions and credentials are in order!


## Any Questions?
> - **DOUBLE CHECK NAMING SYNTAX**, my first time I set step 5, "TFC_AWS_PROVIDER_AUTH" was "TFC_AWS_PROVIDER_**UA**TH"
> - Compare Example Files with Yours
> - Open an '**Issue**' in the top left of the repository and I will try to get to it

### References:
Setting up the Terraform Cloud to AWS OIDC connection (Steps 1-5) from Jorge Pablos.
- https://labinhood.com/blog/2023/02/terraform-cloud-and-aws-via-openid-connect-oidc/

Dives deeper into setting up GitHub with TFC, but has some unneeded code. Still worth the look.
- https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration#configure-aws

Yaml code adapted from this repository to work with GitHub Actions.
- https://github.com/hashicorp-education/learn-terraform-github-actions
- https://developer.hashicorp.com/terraform/tutorials/automation/github-actions
