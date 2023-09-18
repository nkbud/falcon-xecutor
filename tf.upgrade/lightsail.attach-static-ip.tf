
resource "aws_lightsail_static_ip_attachment" "x" {
  depends_on = [null_resource.healthy]
  static_ip_name = var.lightsail_static_ip_name
  instance_name  = var.lightsail_instance_name
  #  lifecycle {
  #    precondition {
  #      condition     = data.http.healthcheck.status_code == 200
  #      error_message = "Selected instance failed to report as healthy. Not re-routing traffic. Failing this deployment."
  #    }
  #  }
}
