# Link to TFC with VCS!!

Follow all of the same steps in the README.md file, but instead of using the API token functionality, use these steps on Hashicorp's site!

https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-vcs-change

Benefits over using API Tokens:
- Handle the Plan and apply steps in a single commit
- No need to cycle tokens, automatically and securely linked to your GitHub repos from TFC account
- Automatically detects changes (with commits) and performs Terraform PLANS upon a PR (Pull request to the branch stated in the TFC account if enabled {see guide^^^} )

Downsides:
- A greater risk of an unwanted APPLY being done if credentials for the TFC account are shared openly (if 'Least Privilege' is not a company policy)
