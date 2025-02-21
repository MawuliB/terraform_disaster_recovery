resource "aws_iam_role" "s3_replication" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "s3_replication_policy" {
  name        = "${var.role_name}-policy"
  description = "Policy for S3 replication"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["s3:GetReplicationConfiguration", "s3:ListBucket"],
        Effect   = "Allow",
        Resource = var.source_bucket_arn
      },
      {
        Action   = ["s3:GetObjectVersion", "s3:GetObjectVersionAcl"],
        Effect   = "Allow",
        Resource = "${var.source_bucket_arn}/*"
      },
      {
        Action   = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"],
        Effect   = "Allow",
        Resource = "${var.destination_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication_attach" {
  role       = aws_iam_role.s3_replication.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}

output "replication_role_arn" {
  description = "The ARN of the S3 replication role"
  value       = aws_iam_role.s3_replication.arn
}
