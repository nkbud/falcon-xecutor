
resource "tls_private_key" "x" {
  rsa_bits  = 2048
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "x" {
  private_key_pem = tls_private_key.x.private_key_pem

  subject {
    common_name  = var.dns_fqdn
    organization = var.app_name
  }
  dns_names = [
    "localhost",
    var.dns_fqdn,
  ]
  validity_period_hours = 24 * 365 * 100 # 100 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

