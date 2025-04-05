output "health_check_alarm_name" {
  description = "The name of the health check CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.route53_health_check_alarm.alarm_name
}