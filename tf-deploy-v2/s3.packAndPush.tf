locals {
  dirpath = "./app"
  zippath = "dockerapp.zip"
}

# pack
data "archive_file" "zip_app" {
  type        = "zip"
  source_dir  = local.dirpath
  output_path = local.zippath
  excludes    = ["${local.dirpath}/node_modules"]
}

# push
resource "aws_s3_object" "push_app" {
  depends_on = [data.archive_file.zip_app]

  bucket = "build-artifacts-0"
  key    = "falcon-xecutor/dockerapp.zip"
  # init.sh depends on this value ^

  source = data.archive_file.zip_app.output_path
  etag   = data.archive_file.zip_app.output_md5
}