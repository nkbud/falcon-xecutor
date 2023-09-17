#
# create self-signed cert
#

resource "tls_private_key" "example" {
  rsa_bits  = 1024
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = var.dns_fqdn
    organization = var.app_name
  }
  dns_names = [
    "localhost",
    var.dns_fqdn,
  ]
  validity_period_hours = 24 * 365 * 100  # 100 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

#
# push it to s3
#

resource "aws_s3_object" "ssl_cert" {
  bucket = var.bucket_name
  key    = "ssl_certificate.pem"

  content = tls_self_signed_cert.example.cert_pem
  etag    = tls_private_key.example.public_key_fingerprint_md5
}
resource "aws_s3_object" "ssl_cert_key" {
  bucket = var.bucket_name
  key    = "ssl_certificate_key.pem"

  content = tls_private_key.example.private_key_pem
  etag    = tls_private_key.example.public_key_fingerprint_md5
}

