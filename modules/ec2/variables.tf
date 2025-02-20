variable "ami_id" {}
variable "instance_type" { default = "t2.micro" }
variable "subnet_id" {}
variable "vpc_id" {}
variable "sg_id" { }
variable "instance_name" { default = "Web Server" }
variable "region" { }