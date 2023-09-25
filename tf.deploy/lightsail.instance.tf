data "aws_availability_zones" "available" {}

locals {

}

resource "aws_lightsail_instance" "x" {
  name = "${var.app_name}-${var.app_version}"
  # name needs a version, since versions must co-exist

  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "micro_3_0"
  # t3.micro
  # 2 vCPU
  # 1 GB memory
  # https://us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#InstanceTypeDetails:instanceType=t3.micro
  # 40 GB SSD
  # 2 TB free transfer (outbound)
  # price for ec2 on-demand: 0.0104  / hour
  # price for lightsail ...: 0.00672 / hour ... 64.6% of full price?

  ip_address_type = "ipv4"
  # ipv6, no thank you

  user_data = local_sensitive_file.startup.content
  # lightsail requires a single string for its user_data
}