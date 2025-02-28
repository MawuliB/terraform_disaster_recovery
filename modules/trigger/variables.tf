variable "health_check_alarm_name" {
  description = "The name of the health check alarm"
  default     = "HealthCheckAlarm"
}

variable "health_check_evaluation_periods" {
  description = "The number of evaluation periods for the health check alarm"
  default     = 1
}

variable "health_check_period" {
  description = "The period (in seconds) for the health check alarm metric"
  default     = 60
}

variable "health_check_threshold" {
  description = "The threshold for the health check alarm"
  default     = 1
}

variable "health_check_id" {
  description = "The ID of the health check to monitor"
}

variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to invoke"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to invoke"
}