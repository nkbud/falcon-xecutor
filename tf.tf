terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
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
  region = var.aws_region
}

locals {
  app_name = "falcon-xecutor"
}


module "infra" {
  source = "./tf.infra"
  app_name = local.app_name

  dns_domain = var.dns_domain
  dns_record = var.dns_record
}
# infra provisions the resources independent of app versions
# that must persist across upgrades


module "v0" {
  source      = "./tf.deploy"
  app_name    = local.app_name
  app_version = "v0"
  aws_region  = var.aws_region
  bucket_name = module.infra.bucket_name
  dns_fqdn    = module.infra.dns_fqdn
  falconx_api_key = var.falconx_api_key
  falconx_passphrase = var.falconx_passphrase
  falconx_secret_key = var.falconx_secret_key
}
#module "v1" {
#  source      = "./deploy"
#}
# versioned modules allow (old, new) instances to co-exist
# by health-checking the (new) instance before re-routing our app traffic
# we allow a "zero-downtime upgrade". see tf.md, "Upgrades"


#module "upgrade" {
#  source      = "./tf.upgrade"
#  app_instance_name = module.v0.app_instance_name
#  app_instance_public_ip = module.v0.app_public_ip
#  app_static_ip_name = module.infra.app_static_ip_name
#}
# see tf.md, "Upgrades"


#module "certbot" {
#  source = "./certbot"
#}
# certbot is a stage 2 upgrade
# where tls.cert.tf pushes a self-signed cert to s3
# certbot will rotate a real letsencrypt cert in s3

#module "newrelic" {
#
#}
# https://registry.terraform.io/providers/newrelic/newrelic/latest/docs
# newrelic is a stage 3 upgrade
# where currently we have to ssh to inspect the various server / logs
# newrelic will allow us to aggregate + inspect the server's logs without ssh
