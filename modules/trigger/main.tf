# # SNS Topic for CloudWatch Alarms
# resource "aws_sns_topic" "route53_health_check_sns" {
#   name = "Route53HealthCheckSNSTopic"
# }

# CloudWatch Alarm that monitors the Route53 health check status
resource "aws_cloudwatch_metric_alarm" "route53_health_check_alarm" {
  alarm_name          = var.health_check_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.health_check_evaluation_periods
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = var.health_check_period
  statistic           = "Minimum"
  threshold           = var.health_check_threshold

  alarm_description = "Route53 health check status alarm for DR"
  alarm_actions     = [var.lambda_function_arn]
  insufficient_data_actions = [var.lambda_function_arn]

  dimensions = {
    HealthCheckId = var.health_check_id
  }
  
}

# resource "aws_cloudwatch_event_rule" "route53_alarm_rule" {
#   name        = "Route53HealthCheckAlarmRule"
#   description = "Trigger Lambda when Route53 health check alarm goes into ALARM state"

#   event_pattern = <<EOF
# {
#   "source": ["aws.sns"],
#   "detail-type": ["SNS Topic Notification"],
#   "detail": {
#     "alarmName": ["${aws_sns_topic.route53_health_check_sns.arn}"]
#   }
# }
# EOF
# }

# resource "aws_cloudwatch_event_target" "lambda_target" {
#   rule      = aws_cloudwatch_event_rule.route53_alarm_rule.name
#   arn       = var.lambda_function_arn
#     target_id = "failover-lambda-target"
# }

# resource "aws_lambda_permission" "allow_eventbridge_invoke" {
#   statement_id  = "AllowExecutionFromEventBridge"
#   action        = "lambda:InvokeFunction"
#   function_name = var.lambda_function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.route53_alarm_rule.arn
# }


# Permission for CloudWatch to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch_invoke" {
  
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "*"
  source_arn    = aws_cloudwatch_metric_alarm.route53_health_check_alarm.arn
}

# Allow SNS to invoke the Lambda function
# resource "aws_lambda_permission" "allow_sns_invoke" {
#   statement_id  = "AllowExecutionFromSNS"
#   action        = "lambda:InvokeFunction"
#   function_name = var.lambda_function_name
#   principal     = "sns.amazonaws.com"
#   source_arn    = aws_sns_topic.route53_health_check_sns.arn
# }

# # SNS Subscription to Lambda
# resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
#   topic_arn = aws_sns_topic.route53_health_check_sns.arn
#   protocol  = "lambda"
#   endpoint  = var.lambda_function_arn
# }
