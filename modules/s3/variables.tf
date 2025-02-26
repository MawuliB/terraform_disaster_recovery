variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}

variable "expiration_days" {
  description = "Number of days after which objects expire."
  type        = number
  default     = 30
}

variable "enable_replication" {
  description = "Whether to enable cross-region replication."
  type        = bool
  default     = false
}

variable "replication_role_arn" {
  description = "ARN of the IAM role for replication."
  type        = string
  default     = ""
}

variable "destination_bucket_arn" {
  description = "ARN of the destination bucket for replication."
  type        = string
  default     = ""
}

variable "destination_storage_class" {
  description = "Storage class for the destination bucket (e.g., STANDARD, STANDARD_IA)."
  type        = string
  default     = "STANDARD"
}

variable "tags" {
  description = "A map of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}
