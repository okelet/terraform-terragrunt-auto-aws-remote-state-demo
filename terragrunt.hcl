remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-state-${get_aws_account_id()}-${get_env("AWS_DEFAULT_REGION", "")}-${get_env("MY_TF_DEPLOYMENT_NAME")}"
    dynamodb_table = "terraform-state-${get_aws_account_id()}-${get_env("AWS_DEFAULT_REGION", "")}-${get_env("MY_TF_DEPLOYMENT_NAME")}"
    key            = "terraform.tfstate"
    region         = get_env("AWS_DEFAULT_REGION")
    encrypt        = true
  }
}
