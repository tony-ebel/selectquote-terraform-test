terraform {
  required_version = ">= 1.13"
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
  region = var.aws_region
}
