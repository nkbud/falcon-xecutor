
resource "aws_lambda_function" "x" {
  depends_on    = [null_resource.image]
  function_name = var.app_name
  role          = aws_iam_role.x.arn

  package_type = "Image"
  image_uri    = local.image_tag

  environment {
    variables = {
      DOMAIN_NAME = var.acme_domain
      BUCKET_NAME = var.s3_bucket_name
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "example" {
  function_name          = aws_lambda_alias.x.function_name
  maximum_retry_attempts = 0
}