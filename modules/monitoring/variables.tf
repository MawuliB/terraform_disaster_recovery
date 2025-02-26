variable "sns_topic_name" {
  description = "Name of the SNS topic for DR alerts"
  type        = string
}

variable "subscription_protocol" {
  description = "Protocol for SNS subscription (email, sms, etc.)"
  type        = string
  default     = "email"
}

variable "subscription_endpoint" {
  description = "Endpoint for SNS subscription (email address, phone number, etc.)"
  type        = string
}

variable "ec2_alarm_name" {
  description = "Name of the CloudWatch alarm for EC2"
  type        = string
}

variable "ec2_evaluation_periods" {
  description = "Number of evaluation periods for the EC2 alarm"
  type        = number
  default     = 2
}

variable "ec2_period" {
  description = "Period (in seconds) for the EC2 alarm metric"
  type        = number
  default     = 300
}

variable "ec2_cpu_threshold" {
  description = "CPU utilization threshold for the EC2 alarm"
  type        = number
  default     = 80
}

variable "ec2_instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "rds_alarm_name" {
  description = "Name of the CloudWatch alarm for RDS"
  type        = string
}

variable "rds_evaluation_periods" {
  description = "Number of evaluation periods for the RDS alarm"
  type        = number
  default     = 2
}

variable "rds_period" {
  description = "Period (in seconds) for the RDS alarm metric"
  type        = number
  default     = 300
}

variable "rds_cpu_threshold" {
  description = "CPU utilization threshold for the RDS alarm"
  type        = number
  default     = 80
}

variable "rds_instance_identifier" {
  description = "The RDS instance identifier to monitor"
  type        = string
}

variable "s3_alarm_name" {
  description = "Name of the CloudWatch alarm for S3"
  type        = string
}

variable "s3_evaluation_periods" {
  description = "Number of evaluation periods for the S3 alarm"
  type        = number
  default     = 1
}

variable "s3_period" {
  description = "Period (in seconds) for the S3 alarm metric"
  type        = number
  default     = 86400  # Typically, S3 metrics are reported daily
}

variable "s3_size_threshold" {
  description = "Threshold for S3 bucket size (in bytes)"
  type        = number
  default     = 10000000000  # e.g., 10GB
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to monitor"
  type        = string
}

variable "tags" {
  description = "Tags to assign to monitoring resources"
  type        = map(string)
  default     = {}
}
