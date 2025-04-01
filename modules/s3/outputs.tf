output "bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.backup.arn
}

output "bucket_name" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.backup.id
}

output "bucket_url" {
  description = "The URL of the S3 bucket."
  value       = "https://${aws_s3_bucket.backup.bucket}.s3.amazonaws.com"
}