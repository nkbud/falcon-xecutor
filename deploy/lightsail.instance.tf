data "aws_availability_zones" "available" {}

resource "aws_lightsail_instance" "x" {
  # create new instance when app files change

  name = local.instance_id
  # a versioned app name

  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = "ubuntu_22_04" # Assuming you want to use Ubuntu
  bundle_id         = "micro_3_0"    # Corresponds to t4g.nano in EC2
  # 2 vCPU
  # 1 GB memory
  # 40 GB SSD
  # 2 TB free transfer outbound

  user_data = join(" && ", local.init_script)
  # lightsail requires a single-line of user_data?

  ip_address_type = "ipv4"
  # don't need or want ipv6

  tags = {
    Name = var.app_name
  }
}
