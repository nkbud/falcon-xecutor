
variable "app_instance_public_ip" {
  description = "lightsail instance's public ipv4 address, used to perform a healthcheck"
}

variable "app_static_ip_name" {
  description = "lightsail static ip name that should always point to a healthy instance of the app"
}

variable "app_instance_name" {
  description = "lightsail instance name to attach the static ip to"
}
