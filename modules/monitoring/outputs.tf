output "sns_topic_arn" {
  description = "ARN of the SNS topic for DR alerts"
  value       = aws_sns_topic.dr_alerts.arn
}
