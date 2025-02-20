variable "vpc_id" {}
variable "subnet_ids" { type = list(string) }
variable "sg_id" {}
variable "elb_name" {}
# variable "instance_id" { }