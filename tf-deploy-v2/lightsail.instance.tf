locals {
  init_script = [
    # install docker
    "sudo apt install docker.io -y",
    # download deployment package
    "sudo snap install awscli --classic",
    "sudo aws s3 cp s3://build-artifacts-0/falcon-xecutor/dockerapp.zip /dockerapp/dockerapp.zip",
    # install unzip and run startup
    "sudo apt install unzip -y",
    "sudo unzip dockerapp/dockerapp.zip -d dockerapp",
    "sudo ./dockerapp/startup.sh"
  ]
  init_script_oneline = join(" && ", local.init_script)
}

data "aws_availability_zones" "available" {}

resource "aws_lightsail_instance" "x" {
  for_each = toset(var.rolling_pair_of_instances)

  name              = "${var.app_name}_${each.key}"
  availability_zone = data.aws_availability_zones.available.names[0]
  blueprint_id      = "ubuntu_22_04" # Assuming you want to use Ubuntu
  bundle_id         = "micro_2_0"    # Corresponds to t4g.nano in EC2
  # 2 vCPU
  # 1 GB memory
  # 40 GB SSD
  # 2 TB free transfer outbound

  user_data = local.init_script_oneline
  # lightsail requires a single-line of user_data

  # we must spin up a new instance
  # if the s3 init script changes
  lifecycle {
    create_before_destroy = true
    # we're going to try and eliminate downtime
    # by keeping the old instance alive for a while
  }
  tags = {
    Name = var.app_name
  }
}

# we wait 6m before destroying the instance
# this gives us time to abort
#resource "time_sleep" "grace_period" {
#  depends_on = [aws_lightsail_instance.x]
#  destroy_duration = "6m"
#}
