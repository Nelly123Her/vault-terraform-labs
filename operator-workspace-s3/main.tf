# Copyright (c) HashiCorp, Inc.

provider "aws" {
  region = var.region

  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

provider "vault" {}

data "terraform_remote_state" "admin" {
  backend = "local"

  config = {
    path = var.vault_state_path
  }
}

data "vault_aws_access_credentials" "creds" {
  backend = data.terraform_remote_state.admin.outputs.backend
  role    = data.terraform_remote_state.admin.outputs.role
}




resource "aws_s3_bucket" "aws-s3" {
  bucket = "${var.project_name}-bucket"

  tags = {
    Name  = "${var.project_name}-instance"
    TTL   = var.ttl
    Owner = "${var.project_name}-guide"
  }
}