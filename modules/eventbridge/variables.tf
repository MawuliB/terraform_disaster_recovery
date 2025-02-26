variable "rule_name" {
  description = "The name of the EventBridge rule"
  type        = string
}

variable "rule_description" {
  description = "A description for the EventBridge rule"
  type        = string
}

variable "event_pattern" {
  description = "The JSON event pattern to trigger the rule"
  type        = string
}

variable "target_id" {
  description = "An identifier for the rule target"
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to invoke"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function (used for permission)"
  type        = string
}
