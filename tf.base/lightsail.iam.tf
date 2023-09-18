
resource "aws_iam_user" "x" {
  name = var.app_name
}
resource "aws_iam_access_key" "x" {
  user = aws_iam_user.x.name
}
# the lightsail instance is given long-lived user credentials
# there is no "ec2 instance profile" "assume role" option
# to do. a short-lived token approach?

resource "aws_iam_user_policy_attachment" "x" {
  user       = aws_iam_user.x.name
  policy_arn = aws_iam_policy.s3.arn
}
# we allow read-only access to our own s3 bucket
# which contains our bootstrap files

resource "aws_iam_policy" "s3" {
  name        = "${var.app_name}-s3"
  description = "Allow ${var.app_name} access to s3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = aws_s3_bucket.x.arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:HeadObject"
        ],
        Resource = "${aws_s3_bucket.x.arn}/*"
      }
    ]
  })
}