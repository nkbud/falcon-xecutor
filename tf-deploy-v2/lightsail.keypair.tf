resource "aws_lightsail_key_pair" "keybase_nkbud" {
  name    = var.app_name
  pgp_key = "keybase:nkbud"
}
