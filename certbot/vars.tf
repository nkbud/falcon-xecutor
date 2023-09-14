
variable "app_name" {
  default = "falcon-xecutor-certbot"
}

variable "s3_bucket_name" {
  default = "falcon-xecutor"
}

variable "s3_object_key" {
  default = "acme.pem"
}

variable "acme_domain" {
  default = "falcon-xecutor.cryptopantheon.info"
}