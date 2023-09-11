resource "aws_lightsail_instance_public_ports" "test" {
  instance_name = aws_lightsail_instance.x.name

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidrs = [

    ]
  }
}