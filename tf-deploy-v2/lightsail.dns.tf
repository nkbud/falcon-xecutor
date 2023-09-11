resource "aws_lightsail_domain" "x" {
  domain_name = "cryptopantheon.info"
}
resource "aws_lightsail_domain_entry" "x" {
  domain_name = aws_lightsail_domain.x.domain_name
  name        = "no-reply"
  type        = "A"
  target      = aws_lightsail_static_ip.x.ip_address
}
