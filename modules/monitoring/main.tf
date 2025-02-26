# Create an SNS Topic for DR alerts
resource "aws_sns_topic" "dr_alerts" {
  name = var.sns_topic_name
  tags = var.tags
}

# Create an SNS Topic Subscription (e.g., Email)
resource "aws_sns_topic_subscription" "dr_alerts_subscription" {
  topic_arn = aws_sns_topic.dr_alerts.arn
  protocol  = var.subscription_protocol   # "email", "sms", etc.
  endpoint  = var.subscription_endpoint
}

# CloudWatch Alarm for EC2 (Example: CPU Utilization)
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = var.ec2_alarm_name
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.ec2_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.ec2_period
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold

  alarm_description = "EC2 CPU Utilization alarm for DR"
  alarm_actions     = [aws_sns_topic.dr_alerts.arn]

  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# CloudWatch Alarm for RDS (Example: CPU Utilization)
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

# CloudWatch Alarm for S3 Bucket Size (Example: BucketSizeBytes)
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
