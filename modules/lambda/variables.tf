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
  default     = "python3.8"
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
