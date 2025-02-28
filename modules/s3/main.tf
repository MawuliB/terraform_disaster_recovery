resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "backup_lifecycle" {
  bucket = aws_s3_bucket.backup.id

  rule {
    id     = "lifecycle"
    status = "Enabled"

    # Expiration settings
    expiration {
      days = var.expiration_days
    }

    # Optional: filter to apply lifecycle to specific prefix/tags
    filter {
      prefix = ""
    }
  }
}

resource "aws_s3_bucket_versioning" "backup_versioning" {
  bucket = aws_s3_bucket.backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Add separate replication configuration resource
resource "aws_s3_bucket_replication_configuration" "replication" {
  # Only create this if replication is enabled
  count = var.enable_replication ? 1 : 0
  
  # Depends on both bucket and versioning
  depends_on = [aws_s3_bucket_versioning.backup_versioning]

  bucket = aws_s3_bucket.backup.id
  role   = var.replication_role_arn

  rule {
    id     = "CRR"
    status = "Enabled"
    
    destination {
      bucket        = var.destination_bucket_arn
      storage_class = var.destination_storage_class
    }
  }
}