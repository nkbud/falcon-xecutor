resource "aws_lightsail_instance_public_ports" "x" {
  instance_name = aws_lightsail_instance.x.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }
  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
  # remove this when you want to apply changes.
  # this resource always 'must be replaced', otherwise.
  #  lifecycle {
  #    ignore_changes = all
  #  }
}