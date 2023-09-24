#
# tls.pem
#

resource "aws_s3_object" "ssl_private_key" {
  bucket  = var.bucket_name
  key     = "${var.app_version}/selfsigned_privkey.pem"
  content = tls_private_key.x.private_key_pem
}
resource "aws_s3_object" "ssl_cert" {
  bucket  = var.bucket_name
  key     = "${var.app_version}/selfsigned_certificate.pem"
  content = tls_self_signed_cert.x.cert_pem
}

#
# nginx.conf
#

resource "aws_s3_object" "nginx" {
  bucket  = var.bucket_name
  key     = "${var.app_version}/nginx.conf"
  content = local_sensitive_file.nginx.content
}

#
# compose.yml
#

resource "aws_s3_object" "compose" {
  bucket  = var.bucket_name
  key     = "${var.app_version}/compose.yml"
  content = local_sensitive_file.compose.content
}

#
# app.zip
#

resource "aws_s3_object" "app" {
  bucket = var.bucket_name
  key    = "${var.app_version}/app.zip"
  source = data.archive_file.app.output_path
  etag   = data.archive_file.app.output_md5
}
data "archive_file" "app" {
  type        = "zip"
  source_dir  = "./app"
  output_path = "app.zip"
  excludes = toset([
    "node_modules",
    "coverage",
    "jest.config.js",
    "readme.md",
    "package-lock.json",
    "lib/*.example.json",
    "lib/*.test.js"
  ])
}

#
# newrelic
#

resource "aws_s3_object" "newrelic" {
  bucket = var.bucket_name
  key = "${var.app_version}/newrelic.yml"
  content = local_sensitive_file.newrelic.content
}