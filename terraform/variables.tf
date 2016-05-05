variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-c8a9baa2"
}

variable "vpc_id" {
  default = "vpc-dd523fb9"
}

variable "subnet_1" {
  default = "10.9.1.0/24"
}

variable "subnet_2" {
  default = "10.9.2.0/24"
}

variable "ssh_from" {
  default = "0.0.0.0/0"
}

variable "policy_path" {}

variable "user_data_path" {}
