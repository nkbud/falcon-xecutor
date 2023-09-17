
locals {
  image_tag = "${aws_ecr_repository.x.repository_url}:latest"
}

resource "null_resource" "image" {
  provisioner "local-exec" {
    command = "docker build --platform linux/amd64 -t lambda:test ${path.module}/lambda"
  }
  provisioner "local-exec" {
    command = "docker tag lambda:test ${local.image_tag}"
  }
  provisioner "local-exec" {
    command = "docker push ${local.image_tag}"
  }
  triggers = {
    always_run = timestamp()
  }
}
