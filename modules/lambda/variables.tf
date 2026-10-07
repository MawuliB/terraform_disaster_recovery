variable "lambda_role_name" {
  description = "The name of the IAM role for the Lambda function"
  type        = string
  default     = "failover_lambda_role"
}

variable "route53_zone_arn" {
  description = "ARN of the Route 53 hosted zone (or its resource)"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the failover Lambda function"
  type        = string
  default     = "FailoverLambda"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda function deployment package zip file"
  type        = string
}

variable "lambda_environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}


variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {}
}
