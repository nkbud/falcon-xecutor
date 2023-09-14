resource "aws_iam_user" "x" {
  name = var.app_name
}

resource "aws_iam_access_key" "x" {
  user = aws_iam_user.x.name
}

resource "aws_iam_user_policy_attachment" "x" {
  user       = aws_iam_user.x.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_iam_policy" "s3_access" {
  name        = "${var.app_name}-s3-bucket"
  description = "Allow ${var.app_name} access to its s3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::falcon-xecutor"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:HeadObject"
        ],
        Resource = "arn:aws:s3:::falcon-xecutor/*"
      }
    ]
  })
}

resource "aws_iam_policy" "y" {
  name        = "${var.app_name}-route53"
  description = "Allow ${var.app_name} access to route 53"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::falcon-xecutor"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:HeadObject"
        ],
        Resource = "arn:aws:s3:::falcon-xecutor/*"
      }
    ]
  })
}
