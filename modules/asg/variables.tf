variable "ami_id" {}
variable "instance_type" { default = "t2.micro" }
variable "security_group_id" {}
variable "subnet_ids" { type = list(string) }
variable "desired_capacity" { default = 2 }
variable "max_size" { default = 4 }
variable "min_size" { default = 1 }
variable "alb_target_group_arn" { }