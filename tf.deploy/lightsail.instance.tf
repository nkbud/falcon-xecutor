data "aws_availability_zones" "available" {}

resource "aws_lightsail_instance" "x" {
  name = "${var.app_name}-${var.app_version}"
  # name needs a version, since versions must co-exist

  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "micro_3_0"
  # 2 vCPU
  # 1 GB memory
  # 40 GB SSD
  # 2 TB free transfer (inbound + outbound)

  ip_address_type = "ipv4"
  # ipv6, no thank you

  user_data = local_sensitive_file.startup.content
  # lightsail requires a single string for its user_data
}
