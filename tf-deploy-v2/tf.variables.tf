
variable "app_name" {
  default = "falcon-executor"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "rolling_pair_of_instances" {
  description = "a list of 2 strings, [prev, curr], that allows a safe rolling restart"
}