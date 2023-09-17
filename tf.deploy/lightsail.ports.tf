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
  lifecycle {
    ignore_changes = all
  }
  # this resource doesn't behave well
  # it keeps wanting to replace itself
  # remove this block if you actually want it to be replaced
}