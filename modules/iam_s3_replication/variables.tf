variable "role_name" {
  description = "Name for the S3 replication IAM role."
  type        = string
  default     = "s3_replication_role"
}

variable "source_bucket_arn" {
  description = "ARN of the source S3 bucket (for replication)."
  type        = string
}

variable "destination_bucket_arn" {
  description = "ARN of the destination S3 bucket (for replication)."
  type        = string
}
