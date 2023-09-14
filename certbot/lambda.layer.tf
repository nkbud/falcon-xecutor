
locals {
  pip_source   = "${path.module}/layer"
  pip_target   = "${path.module}/layer.zip"
  pip_installs = ["acme"]
}

resource "null_resource" "prepare_lambda_layer" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${local.pip_source}
      pip install ${join(" ", local.pip_installs)} -t ${local.pip_source}
      zip -r ${local.pip_target} ${local.pip_source}/
    EOT
  }
  triggers = {
    rerun_on_change = join(" ", local.pip_installs)
  }
}

resource "aws_lambda_layer_version" "pip" {
  depends_on = [null_resource.prepare_lambda_layer]

  filename            = local.pip_target
  layer_name          = join("_", local.pip_installs)
  source_code_hash    = filebase64sha256(local.pip_target)
  compatible_runtimes = ["python3.9", "python3.10", "python3.11"]
}



