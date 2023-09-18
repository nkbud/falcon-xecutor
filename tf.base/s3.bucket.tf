
resource "aws_s3_bucket" "x" {
  bucket        = "falcon-xecutor"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.x.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}