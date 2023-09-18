#
# inputs
#

variable "letsencrypt_cert_is_ready" {
  description = "See oioio-dev/lambda-certbot. You must already have certs in s3 for you domain."
  default = true
}
variable "aws_region" {}
variable "app_name" {}
variable "app_version" {}
variable "bucket_name" {}
variable "dns_fqdn" {}
variable "falconx_api_key" {
  sensitive = true
}
variable "falconx_passphrase" {
  sensitive = true
}
variable "falconx_secret_key" {
  sensitive = true
}
variable "iam_access_key" {
  sensitive = true
}
variable "iam_secret_key" {
  sensitive = true
}

#
# outputs
#

output "app_instance_name" {
  value = aws_lightsail_instance.x.name
}
output "app_public_ip" {
  value = aws_lightsail_instance.x.public_ip_address
}
