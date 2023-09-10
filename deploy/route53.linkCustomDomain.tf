resource "aws_route53_record" "x" {
  zone_id = "Z04099252SO7EPOX5QTR7"
  # the "data" lookup was causing problems
  # "cryptopantheon.info"

  name    = "no-reply.cryptopantheon.info"
  type    = "A"
  records = [aws_eip.x.public_ip]
  ttl     = "60"
}
