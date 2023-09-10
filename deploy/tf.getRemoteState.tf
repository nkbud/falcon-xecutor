#data "terraform_remote_state" "remote_state" {
#  backend = "s3"
#
#  config = {
#    bucket = "terraform-0"
#    key    = "aws.infra.terraform.tfstate"
#    region = "us-east-1"
#  }
#}

locals {
  oioio_allow_all_security_group_id = "sg-09629c9cc3bc8930f"
  oioio_http_https_security_group_id = "sg-06fc35ad75408ddcb"
  oioio_public_subnet_id = "subnet-04b9422753f2c9ae5"
  oioio_ssh_http_https_security_group_id = "sg-05b5941aa1921e5b4"
  oioio_vpc_id = "vpc-0568861b1ee8d3c1a"

  pantheon_allow_all_security_group_id = "sg-02d4f8e502226cc4f"
  pantheon_http_https_security_group_id = "sg-0edf1c34aa1d7e862"
  pantheon_public_subnet_id = "subnet-0ba41772dd417a153"
  pantheon_ssh_http_https_security_group_id = "sg-064a4d458d2f54a3b"
  pantheon_vpc_id = "vpc-0fff99019cac6e904"
}

