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
  region = local.aws_region
}

locals {
  aws_region = "us-east-1"
  app_name   = "falcon-xecutor"
}

module "infra" {
  source   = "./tf.base"
  app_name = local.app_name
  dns_domain = var.dns_domain
  dns_record = var.dns_record
}
# the resources independent of app versions


locals {
  ordered_versions = split(",", var.deploy)
  old_version = local.ordered_versions[0]
  new_version = reverse(local.ordered_versions)[0]
  # try to make the newest version the active recipient of traffic. i.e. ['v0', 'v1'] --> 'v1'
}

module "app" {
  for_each           = toset(local.ordered_versions)
  source             = "./tf.deploy"
  app_name           = local.app_name
  app_version        = each.key

  aws_region         = local.aws_region
  bucket_name        = module.infra.bucket_name
  dns_fqdn           = module.infra.dns_fqdn
  iam_access_key     = module.infra.iam_access_key
  iam_secret_key     = module.infra.iam_secret_key

  falconx_api_key    = var.falconx_api_key
  falconx_passphrase = var.falconx_passphrase
  falconx_secret_key = var.falconx_secret_key
}

module "upgrade" {
  source = "./tf.upgrade"
  lightsail_static_ip_name = module.infra.app_static_ip_name
  lightsail_instance_name  = module.app[local.new_version].app_instance_name
  healthcheck_public_ip    = module.app[local.new_version].app_public_ip
}
# this switches traffic over to the 'active version' of the app
# it includes a healthcheck that can fail the deployment
# protecting us from entering a bad state

# should have a way to say what is the "active" instance
# ...
output "currently_active_instance" {
  value = module.upgrade.healthcheck_passed ? local.new_version : local.old_version
}