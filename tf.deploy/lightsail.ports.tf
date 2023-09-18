resource "aws_lightsail_instance_public_ports" "x" {
  instance_name = aws_lightsail_instance.x.name

  port_info {
    protocol          = "all"
    from_port         = 0
    to_port           = 65535
    cidr_list_aliases = []
    cidrs             = ["0.0.0.0/0"]
    ipv6_cidrs        = ["::/0"]
  }
  lifecycle {
    ignore_changes = [port_info]
  }
}