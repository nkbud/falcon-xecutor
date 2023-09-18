#
# inputs
#

variable "deploy" {
  validation {
    condition = contains([
      "blue",        # 1 instance, using 'blue' templates.
      "green",       #                   'green'
      "blue,green",  # 2 instances, attempt to transfer traffic from 'blue' to 'green' instance
      "green,blue"   #                                               'green' to 'blue'
    ], var.deploy)
    error_message = "We only support blue / green deployments. Choose one."
  }
  description = <<-EOT
    Options:
    - blue
    - green
    - blue,green
    - green,blue
    EOT
}

variable "dns_domain" {}
variable "dns_record" {}

variable "falconx_api_key" {
  sensitive = true
}
variable "falconx_passphrase" {
  sensitive = true
}
variable "falconx_secret_key" {
  sensitive = true
}

variable "new_relic_license_key" {
  sensitive = true
}
variable "new_relic_api_key" {
  sensitive = true
}
variable "new_relic_account_id" {
  sensitive = true
}
