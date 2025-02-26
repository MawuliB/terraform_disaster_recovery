output "event_rule_arn" {
  description = "The ARN of the created EventBridge rule"
  value       = aws_cloudwatch_event_rule.failover_rule.arn
}
