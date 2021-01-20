provider "aws" {
}

data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
  state = "available"
}

terraform {
  backend "s3" {}
}
