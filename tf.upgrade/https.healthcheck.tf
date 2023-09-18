
data "http" "healthcheck" {
  url                = "https://${var.healthcheck_public_ip}/health"
  method             = "GET"
  insecure           = true
  request_timeout_ms = 5000
  retry {
    attempts     = 12 * 5  # 2.5 minutes is sufficient, 5 minutes is plenty.
    min_delay_ms = 5000
    max_delay_ms = 5000
  }
}
resource "null_resource" "healthy" {
  lifecycle {
    precondition {
      condition     = data.http.healthcheck.status_code == 200
      error_message = "Selected instance failed to report as healthy. Not re-routing traffic. Failing this deployment."
    }
  }
}