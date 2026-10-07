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

  alarm_description         = "Route53 health check status alarm for DR"
  alarm_actions             = [var.lambda_function_arn]
  insufficient_data_actions = [var.lambda_function_arn]

  dimensions = {
    HealthCheckId = var.health_check_id
  }

}


# Permission for CloudWatch to invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch_invoke" {

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "*"
  source_arn    = aws_cloudwatch_metric_alarm.route53_health_check_alarm.arn
}