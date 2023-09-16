
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/fn/main.py"
  output_path = "${path.module}/main.py"
}

resource "aws_lambda_function" "x" {
  function_name = var.app_name
  runtime       = "python3.10"
  role          = aws_iam_role.x.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  handler          = "main.handler"
  layers = [
    aws_lambda_layer_version.pip.arn
  ]

  environment {
    variables = {
      DOMAIN_NAME = var.acme_domain
      BUCKET_NAME = var.s3_bucket_name
      OBJECT_KEY  = var.s3_object_key
      ACME_KEY    = tls_private_key.acme_key.private_key_pem
      ZONE_ID     = data.aws_route53_zone.x.id
    }
  }
}

resource "tls_private_key" "acme_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

locals {
  a = split(".", var.acme_domain)
  b = slice(local.a, 1, length(local.a))
  c = join(".", local.b)
}
data "aws_route53_zone" "x" {
  name = local.c
}