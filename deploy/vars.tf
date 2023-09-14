variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {

}
variable "app_version" {

}
locals {
  instance_id = "${var.app_name}_${var.app_version}"
}

output "app_instance_name" {
  value = local.instance_id
}
output "app_public_ip" {
  value = aws_lightsail_instance.x.public_ip_address
}
output "app_static_ip_name" {
  value = aws_lightsail_static_ip.x.name
}
