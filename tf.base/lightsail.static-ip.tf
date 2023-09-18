
# we provision a single static ipv4 address
# this must always be attached to a healthy instance
# see "update"
resource "aws_lightsail_static_ip" "x" {
  name = var.app_name
  lifecycle {
    prevent_destroy = true
    # this catches accidents.
    # comment out if you really want a new static ip
    # thanks to DNS uncertainty, that may cause downtime of indeterminate length
  }
}
