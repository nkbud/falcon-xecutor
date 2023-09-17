
# here's an interesting method to prevent a static ip reattachment
# we poll the new instance's public ip for health
# and only if it's healthy do we reassign the DNS-linked static ip to the new instance
data "http" "new_instance_is_healthy" {
  url                = "http://${var.app_instance_public_ip}/health"
  method             = "GET"
  insecure           = true
  request_timeout_ms = 5000
  retry {
    attempts     = 60
    min_delay_ms = 5000
    max_delay_ms = 5000
  }
}