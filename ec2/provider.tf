terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.69.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}


provider "vault" {
  address = var.vault_addr
  token   = var.vault_token  # Your Vault token (root token or another token with permissions)
}

# Retrieve AWS credentials from Vault's KV store
data "vault_generic_secret" "aws_creds" {
  path = "secret/aws"  # Adjust this to match the path where your AWS credentials are stored
}

# Configure the AWS provider using credentials retrieved from Vault
provider "aws" {
  region     = var.aws_region
  access_key = data.vault_generic_secret.aws_creds.data["access_key"]
  secret_key = data.vault_generic_secret.aws_creds.data["secret_key"]
}