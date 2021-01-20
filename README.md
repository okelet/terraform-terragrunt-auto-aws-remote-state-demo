
# Terraform/Terragrunt remote state demo

This repo contains a sample, basic [Terraform](https://www.terraform.io/) project, that uses [Terragrunt](https://terragrunt.gruntwork.io/) for the automatic creation of the state storage in AWS (S3 bucket and DynamoDB table) (this project doesn't use any of all the other features of Terragrunt, just the state creation and usage).

This sample uses an S3 bucket and a DynamoDB table, in the current account, with the account ID, region and app/project name in their names, so they should be unique across AWS (S3 bucket names must be unique), like `terraform-state-012345678910-us-east-1-myapp`.

```bash
export MY_TF_DEPLOYMENT_NAME=myapp
export MY_TF_WORKSPACE=dev
terragrunt workspace new $MY_TF_WORKSPACE || true
terragrunt workspace select $MY_TF_WORKSPACE
terragrunt workspace show
terragrunt init -upgrade
```

Plan:

```bash
terragrunt plan
```

Apply:

```bash
terragrunt apply -auto-approve
```

Destroy:

```bash
terragrunt destroy -auto-approve
```
