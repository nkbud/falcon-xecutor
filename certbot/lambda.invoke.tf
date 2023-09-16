# we have a rate(X days) cloudwatch event
# but that doesn't trigger immediately, so we need something like this

#resource "aws_lambda_invocation" "example" {
#  function_name = aws_lambda_function.x.function_name
#  input         = ""
#
#  triggers = {
#    change_to_rerun = "a"
#  }
#}