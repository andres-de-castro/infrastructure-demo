# This is where variables to be autoloaded by Terraform go
variable "aws_region" {
  type    = "string"
  default = "us-east-1"
}

variable "environment" {
  type    = "string"
  default = "production"
}

variable "vpc_cidr_block" {
  type    = "string"
  default = "172.16.0.0/16"
}

variable "public_cidr_blocks" {
  type = "list"

  default = [
    "172.16.254.0/25",
    "172.16.254.128/25",
  ]
}

variable "private_cidr_blocks" {
  type = "list"

  default = [
    "172.16.0.0/24",
    "172.16.1.0/24",
  ]
}

variable "secret_key" {
  type    = "string"
  default = "mysupernotsecretkey"
}
