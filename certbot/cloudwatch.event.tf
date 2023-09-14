
# the first invocation
# |
# the subsequent invocations
resource "aws_cloudwatch_event_rule" "x" {
  name                = "${var.app_name}-every-7-days"
  description         = "Fires ${var.app_name} every 7 days"
  schedule_expression = "rate(7 days)"
}
resource "aws_cloudwatch_event_target" "x" {
  rule      = aws_cloudwatch_event_rule.x.name
  target_id = "InvokeLambdaFunction"
  arn       = aws_lambda_function.x.arn
}
resource "aws_lambda_permission" "x" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.x.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.x.arn
}