variable "vault_addr" {
  description = "The address of the Vault server"
  type        = string
  default     = "http://127.0.0.1:8200"  # Hardcoded Vault address
}

variable "vault_token" {
  description = "The token authentication"
  type        = string
  default     = ""#  # Hardcoded role ID
}


variable "aws_region" {
    description = "AWS region to use"
    type = string
    default = "us-east-2"
  
}