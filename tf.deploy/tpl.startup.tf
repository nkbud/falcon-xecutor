#
# startup.sh
#

resource "local_sensitive_file" "startup" {
  filename = "${path.module}/out/startup.sh"
  content  = join("\n", [
    "#!/bin/bash",
    replace(local.startup_sh, "#!/bin/bash", "")
  ])
}
locals {
  startup_vars = {
    startup_aws = local_sensitive_file.aws.content
    startup_app = local_sensitive_file.app.content
    startup_nginx = local_sensitive_file.nginx.content
  }
}
locals {
  startup_sh = templatefile(
    "${path.module}/tpl/sh.startup.tftpl",
    local.startup_vars
  )
}