data "aws_route53_zone" "x" {
  name = var.dns_domain
}

resource "aws_route53_record" "x" {
  zone_id = data.aws_route53_zone.x.zone_id
  name    = "${var.dns_record}.${var.dns_domain}"
  type    = "A"
  records = [aws_lightsail_static_ip.x.ip_address]
  ttl     = 300
}