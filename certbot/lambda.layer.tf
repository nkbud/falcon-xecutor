
locals {
  pip_target   = "${path.module}/fn/python"
  zip_source   = "${path.module}/fn/"
  zip_target   = "${path.module}/layer.zip"
  pip_installs = ["acme"]

  docker_run_command = "docker run -v ${path.root}:/pip python:3.10-slim-buster"
  pip_install_command = "pip install --upgrade ${join(" ", local.pip_installs)} -t /pip/${local.pip_target}"
}

resource "null_resource" "pip" {
  provisioner "local-exec" {
    command = "${local.docker_run_command} ${local.pip_install_command}"
  }
  triggers = {
    always_run = timestamp()
  }
}

data "archive_file" "pip" {
  depends_on  = [null_resource.pip]
  type        = "zip"
  source_dir  = local.zip_source
  output_path = local.zip_target
  excludes    = toset(["main.py"])
}

resource "aws_lambda_layer_version" "pip" {
  depends_on = [data.archive_file.pip]
  layer_name = join("_", local.pip_installs)

  filename         = local.zip_target
  source_code_hash = filebase64sha256("${local.zip_source}/main.py")

  compatible_runtimes = ["python3.10"]
}



