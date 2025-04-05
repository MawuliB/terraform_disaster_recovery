variable "ami_id" {
    description = "The AMI ID to use for the EC2 instances"
}
variable "instance_type" { default = "t2.micro" }
variable "security_group_id" {
    description = "The security group ID to use for the EC2 instances"
}
variable "subnet_ids" { type = list(string) }
variable "desired_capacity" { default = 2 }
variable "max_size" { default = 4 }
variable "min_size" { default = 1 }
variable "alb_target_group_arn" { }
variable "use_dr" {
  description = "Toggle to determine whether to use DR (Disaster Recovery)"
  type        = bool
  default     = false
}
variable "primary_bucket_url" {
  description = "The URL of the primary bucket"
}
variable "secondary_bucket_url" {
  description = "The URL of the secondary bucket"
}
variable "primary_db_endpoint" {
  description = "The primary DB endpoint"
}
variable "secondary_db_endpoint" {
  description = "The secondary DB endpoint"
}