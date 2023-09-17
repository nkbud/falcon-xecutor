#
# nginx.conf
#

resource "local_sensitive_file" "nginx" {
  filename = "${path.module}/out/nginx.sh"
  content  = templatefile(
    "${path.module}/tpl/sh.nginx.tftpl",
    local.nginx_vars
  )
}
locals {
  nginx_vars = {
    app_port = "1000"
    server_name = var.dns_fqdn
    bucket_name = var.bucket_name
    ssl_cert_object_key = aws_s3_object.ssl_cert.key
    ssl_cert_key_object_key = aws_s3_object.ssl_cert_key.key
  }
}
