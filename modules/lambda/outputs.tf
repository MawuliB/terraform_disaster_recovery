output "failover_lambda_arn" {
  description = "The ARN of the failover Lambda function"
  value       = aws_lambda_function.failover_lambda.arn
}
