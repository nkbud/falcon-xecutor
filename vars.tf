#
# inputs
#

variable "prod" {
  default     = null
  description = <<-EOT
    Options:
    - blue
    - green
    - (null)
    EOT
}

variable "dev" {
  default     = null
  description = <<-EOT
    Options:
    - blue
    - green
    - (null)
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
