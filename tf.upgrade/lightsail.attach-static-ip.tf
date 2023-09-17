
# this reassigns our static ip to our upgraded instance
resource "aws_lightsail_static_ip_attachment" "x" {
  static_ip_name = var.app_static_ip_name
  instance_name  = var.app_instance_name


  #  lifecycle {
  #    precondition {
  #      condition     = data.http.new_instance_is_healthy.status_code == 200
  #      error_message = "the new instance failed to report as healthy. will not re-attach static ip"
  #    }
  #  }
}

