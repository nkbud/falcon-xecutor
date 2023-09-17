#
# app.sh
#

resource "local_sensitive_file" "app" {
  filename = "${path.module}/out/app.sh"
  content  = templatefile(
    "${path.module}/tpl/sh.app.tftpl",
    local.app_vars
  )
}
locals {
  app_vars = {
    bucket_name = var.bucket_name
    app_object_key = aws_s3_object.app.key
    app_port = 1000
    falconx_api_key = var.falconx_api_key
    falconx_passphrase = var.falconx_passphrase
    falconx_secret_key = var.falconx_secret_key
  }
}
