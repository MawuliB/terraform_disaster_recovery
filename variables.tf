variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_region_secondary" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_region_recover" {
  description = "AWS region"
  default     = "us-east-1"
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

variable "primary_bucket_name" {
  description = "The name of the primary bucket"
}

variable "secondary_bucket_name" {
  description = "The name of the secondary bucket"
}

variable "hosted_zone_id" {
  description = "The Route 53 hosted zone ID"
}

variable "domain_name" {
  description = "The domain name"
}

variable "primary_fqdn" {
  description = "The primary FQDN"
}

variable "health_check_port" {
  description = "The health check port"
  default     = 80
}

variable "health_check_type" {
  description = "The health check type"
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "The health check interval"
  default     = 30
}

variable "health_check_failure_threshold" {
  description = "The health check failure threshold"
  default     = 3
}

variable "alert_email" {
  description = "The email address to send alerts to"
}