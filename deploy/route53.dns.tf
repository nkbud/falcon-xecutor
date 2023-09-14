data "aws_route53_zone" "x" {
  name = "cryptopantheon.info"
}

resource "aws_route53_record" "x" {
  zone_id = data.aws_route53_zone.x.zone_id
  name    = "${var.app_name}.${data.aws_route53_zone.x.name}"
  type    = "A"
  ttl     = 300
  records = [aws_lightsail_static_ip.x.ip_address]
}