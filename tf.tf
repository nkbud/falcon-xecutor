terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-0"
    key     = "falcon-executor-v2.terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
}

locals {
  app_name = "falcon-xecutor"
}

# certbot is a lambda function
# that obtains and renews CA-signed TLS certificates
# pushing them into to an s3 bucket
module "certbot" {
  source = "./certbot"
}

# /deploy encapsulates a lightsail VPS
//
module "v0-1-0" {
  source      = "./deploy"
  app_name    = local.app_name
  app_version = "v0.1.0"
}

module "attach" {
  source                 = "./upgrade"
  app_instance_name      = module.v0-1-0.app_instance_name
  app_instance_public_ip = module.v0-1-0.app_public_ip
  app_static_ip_name     = module.v0-1-0.app_static_ip_name
}
