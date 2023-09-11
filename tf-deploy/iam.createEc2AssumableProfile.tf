resource "aws_iam_instance_profile" "x" {
  name = var.app_name
  role = aws_iam_role.x.name
}

resource "aws_iam_role" "x" {
  name = var.app_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}