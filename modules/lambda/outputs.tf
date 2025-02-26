output "failover_lambda_arn" {
  description = "The ARN of the failover Lambda function"
  value       = aws_lambda_function.failover_lambda.arn
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.failover_lambda.function_name
}