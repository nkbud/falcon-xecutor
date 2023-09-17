
variable "app_name" {}
variable "dns_domain" {}
variable "dns_record" {}

output "app_static_ip_name" {
  value = aws_lightsail_static_ip.x.name
}
output "app_static_ip_address" {
  value = aws_lightsail_static_ip.x.ip_address
}

output "dns_domain" {
  value = var.dns_domain
}
output "dns_subdomain" {
  value = var.dns_record
}
output "dns_fqdn" {
  value = aws_route53_record.x.fqdn
}

output "bucket_name" {
  value = aws_s3_bucket.x.bucket
}
output "bucket_arn" {
  value = aws_s3_bucket.x.arn
}