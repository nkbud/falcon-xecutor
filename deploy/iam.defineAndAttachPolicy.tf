resource "aws_iam_role_policy_attachment" "x" {
  policy_arn = aws_iam_policy.x.arn
  role       = aws_iam_role.x.name
}

resource "aws_iam_policy" "x" {
  name        = var.app_name
  description = "Allow falcon-xecutor EC2 to do stuff"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # get its files from the s3 bucket
      {
        Action   = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::build-artifacts-0",
      },
      {
        Action   = [
          "s3:GetObject",
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::build-artifacts-0/falcon-xecutor/*"
      }
    ]
  })
}
