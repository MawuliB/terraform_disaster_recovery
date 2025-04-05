output "sns_topic_arn" {
  description = "ARN of the SNS topic for DR alerts"
  value       = aws_sns_topic.dr_alerts.arn
}

output "asg_alarm_name" {
  description = "The name of the ASG CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.asg_inservice_alarm.alarm_name
}