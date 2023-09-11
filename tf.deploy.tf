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

# a fancy way to get the previous timestamp
# this allows for a pseudo rolling restart
data "terraform_remote_state" "remote_state" {
  backend = "s3"
  config = {
    bucket = "terraform-0"
    key    = "falcon-xecutor.terraform.tfstate"
    region = "us-east-1"
  }
}
locals {
  curr = timestamp()
  prev = data.terraform_remote_state.remote_state.curr
}
module "deploy" {
  source = "tf-deploy-v2"
  # i think this will allow us to create a new instance
  # and keep the old one around
  # until we can verify the new instance is healthy
  # where we can --target destroy the old one
  rolling_pair_of_instances = toset([
    local.prev,
    local.curr
  ])
}
