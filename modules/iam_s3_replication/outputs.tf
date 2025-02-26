output "replication_role_arn" {
  description = "The ARN of the S3 replication role"
  value       = aws_iam_role.s3_replication.arn
}