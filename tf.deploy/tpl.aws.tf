#
# .aws/config
# .aws/credentials
#

resource "local_sensitive_file" "aws" {
  filename = "${path.module}/out/aws.sh"
  content  = templatefile(
    "${path.module}/tpl/sh.aws.tftpl",
    local.aws_vars
  )
}
locals {
  aws_vars = {
    aws_access_key_id = aws_iam_access_key.x.id
    aws_secret_access_key = aws_iam_access_key.x.secret
    aws_region = var.aws_region
  }
}

