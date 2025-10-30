terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "selectquote-test-tf-state"
    key    = "default.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-west-2"
}
