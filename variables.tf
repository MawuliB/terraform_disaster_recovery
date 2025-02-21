variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_region_secondary" {
  description = "AWS region"
  default     = "eu-west-2"
}

variable "ami_id_primary" {
  description = "The AMI ID to use for the EC2 instances"
}

variable "ami_id_secondary" {
  description = "The AMI ID to use for the EC2 instances"
}

variable "instance_type" {
  description = "The instance type to use for the EC2 instances"
  default     = "t3.micro"
}

variable "db_username" {
  description = "The username for the database"
  default     = "admin"
}

variable "db_password" {
  description = "The password for the database"
  default     = "password"
}

variable "db_parameter_group" {
  description = "The name of the DB parameter group"
}

variable "db_subnet_group" {
  description = "The DB subnet group name"
}