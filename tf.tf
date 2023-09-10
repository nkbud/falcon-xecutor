terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-0"
    key     = "falcon-executor.terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
}

module "deploy" {
  source = "./deploy"
}