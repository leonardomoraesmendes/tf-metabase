terraform {
  # backend "s3" {
  #   bucket = "<bucket-name>"
  #   key    = "metabase.tfstate"
  #   region = "us-east-1"
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.71.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  token      = var.aws_session_token
}