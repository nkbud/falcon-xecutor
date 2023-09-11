resource "aws_instance" "x" {
  tags = {
    Name = var.app_name
  }

  ami = "ami-06531f5aac8d61d16"
  # ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-20230829-8bb3c36c-1075-40ef-adf8-e9bcd0ccb212

  instance_type = "t4g.nano"
  # 2 vCPU
  # 0.5 GB memory
  # arm64
  # $3/mth

  user_data = file("${path.module}/ec2.ubuntu-docker-aws.init.sh")
  // startup sequence, pretty hefty
  user_data_replace_on_change = true
  # anytime we change the startup script, we need to restart
  # anytime we push a new s3 object (changing the input files), we restart
  lifecycle {
    replace_triggered_by = [
      aws_s3_object.push_app
    ]
    create_before_destroy = true
    # and create_before_destroy will help reduce downtime
    # we might be able to get downtime to 0 if we have a fast enough boot
    # or wait long enough to destroy our old instance
  }

  vpc_security_group_ids = [
    local.pantheon_ssh_http_https_security_group_id
  ]
  # allow ssh, http, and https
  key_name = "swiftx22"
  # turn off ssh at some point?
  # i have the only private key.

  subnet_id = local.pantheon_public_subnet_id
  # run in the pantheon public subnet


  iam_instance_profile = aws_iam_instance_profile.x.id
  # using these permissions

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }
  volume_tags = {
    Name : var.app_name
  }
  # our 8GB root volume
}