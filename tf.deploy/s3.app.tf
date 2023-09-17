#
# pack
#

data "archive_file" "dockerapp" {
  type        = "zip"
  source_dir  = "./app"
  output_path = "dockerapp.zip"
  excludes = toset([
    "node_modules",
    "coverage",
    "jest.config.js",
    "readme.md",
    "package-lock.json",
    "lib/*.example.json",
    "lib/*.test.js"
  ])
}

#
# push
#

resource "aws_s3_object" "app" {
  bucket = var.bucket_name
  key    = "dockerapp.zip"

  source = data.archive_file.dockerapp.output_path
  etag   = data.archive_file.dockerapp.output_md5
}