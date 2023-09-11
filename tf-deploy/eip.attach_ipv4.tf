resource "aws_eip" "x" {
  domain = "vpc"

  instance                  = aws_instance.x.id
  associate_with_private_ip = aws_instance.x.private_ip

  tags = {
    Name : var.app_name
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.x.id
  allocation_id = aws_eip.x.id
}