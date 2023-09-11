# we provision a single static ip that gets attached to new instances.
resource "aws_lightsail_static_ip" "x" {
  lifecycle {
    prevent_destroy = true
    # this catches accidents.
    # comment out if you really want a new static ip
    # thanks to DNS uncertainty, this may cause downtime of indeterminate length
  }
  name = var.app_name
}

# here's an interesting method to prevent a static ip reattachment
# we poll the new instance's public ip for health
# and only if it's healthy do we reassign the DNS-linked static ip to the new instance
locals {
  new_instance_id = var.rolling_pair_of_instances[1]
  new_instance_ip = aws_lightsail_instance.x[local.new_instance_id].public_ip_address
}
data "http" "new_instance_is_healthy" {
  url = "https://${local.new_instance_ip}/health"
  method = "GET"
  insecure_skip_verify = true
  request_timeout_ms = 5000
  retry {
    attempts = 60
    min_delay_ms = 5000
    max_delay_ms = 5000
  }
}
# we re-assign the single static ip to the new instance
resource "aws_lightsail_static_ip_attachment" "x" {
  static_ip_name = aws_lightsail_static_ip.x.name
  instance_name  = aws_lightsail_instance.x.name
  lifecycle {
    precondition {
      condition = data.http.new_instance_is_healthy
    }
  }
}
