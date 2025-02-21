resource "aws_s3_bucket" "backup" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-backups"
    enabled = true
    prefix = ""

    expiration {
      days = var.expiration_days
    }
  }

  dynamic "replication_configuration" {
    for_each = var.enable_replication ? [1] : []
    content {
      role = var.replication_role_arn
      rules {
        id     = "CRR"
        status = "Enabled"
        prefix = ""
        destination {
          bucket        = var.destination_bucket_arn
          storage_class = var.destination_storage_class
        }
      }
    }
  }

  tags = var.tags
}
