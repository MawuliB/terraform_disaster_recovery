# Create an SNS Topic for DR alerts
resource "aws_sns_topic" "dr_alerts" {
  name = var.sns_topic_name
  tags = var.tags
}

# Create an SNS Topic Subscription
resource "aws_sns_topic_subscription" "dr_alerts_subscription" {
  topic_arn = aws_sns_topic.dr_alerts.arn
  protocol  = var.subscription_protocol   # "email", "sms"
  endpoint  = var.subscription_endpoint
}

# CloudWatch Alarm for EC2 (CPU Utilization)
# CloudWatch Alarm for the Auto Scaling Group (Primary)
resource "aws_cloudwatch_metric_alarm" "asg_inservice_alarm" {
  alarm_name          = var.asg_alarm_name
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.asg_evaluation_periods
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = var.asg_period
  statistic           = "Minimum"
  threshold           = var.asg_inservice_threshold

  alarm_description = "ASG in-service instance count below threshold"
  alarm_actions     = [aws_sns_topic.dr_alerts.arn]

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# CloudWatch Alarm for RDS (CPU Utilization)
resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = var.rds_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.rds_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.rds_period
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold

  alarm_description = "RDS CPU Utilization alarm for DR"
  alarm_actions     = [aws_sns_topic.dr_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }
}

# CloudWatch Alarm for S3 Bucket Size (BucketSizeBytes)
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size_alarm" {
  alarm_name          = var.s3_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.s3_evaluation_periods
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = var.s3_period
  statistic           = "Average"
  threshold           = var.s3_size_threshold

  alarm_description = "S3 Bucket size alarm for DR"
  alarm_actions     = [aws_sns_topic.dr_alerts.arn]

  dimensions = {
    BucketName  = var.s3_bucket_name,
    StorageType = "StandardStorage"
  }
}
