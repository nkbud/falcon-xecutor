
# this healthcheck signals that our new instance is ready
# and the CREATE has been successful
# we are now approved to DESTROY the deposed instance
data "http" "healthcheck" {
  depends_on = [module.deploy]
  # we wait for the new instance to come alive,
  # and then we healthcheck against it
  url                = "https://no-reply.cryptopantheon.info/health"
  method             = "GET"
  request_timeout_ms = 5000
  retry {
    attempts     = 60
    min_delay_ms = 5000
    max_delay_ms = 5000
    # 5s * 60 = allow 5 mins to startup
  }
}

locals {
  old_instance_address = "module.deploy.aws_lightsail_instance.x[${local.prev}]"
  # we'll have to use a different command if this messes up the .tfstate
}

resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "terraform destroy -target=${old_instance_address} -auto-approve"
  }
  lifecycle {
    precondition {
      condition = data.http.healthcheck.status_code == 200
      error_message = "the new instance healthcheck has failed. cannot destroy old instance."
    }
  }
}