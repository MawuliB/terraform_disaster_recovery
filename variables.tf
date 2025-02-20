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