resource "aws_db_instance" "read_replica" {
  replicate_source_db    = var.source_db_instance_identifier
  instance_class         = var.instance_class
  identifier             = var.identifier
  engine                 = var.engine
  engine_version         = var.engine_version
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = false
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.replica_encryption_key.arn
  skip_final_snapshot    = true
  # final_snapshot_identifier = "${var.identifier}-final-snapshot"

  tags = var.tags
}

resource "aws_db_subnet_group" "default" {
  name       = "dr-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "DR DB Subnet Group"
  }
}

# Add KMS key in the destination (secondary) region
resource "aws_kms_key" "replica_encryption_key" {
  description             = "KMS key for RDS read replica encryption"
  deletion_window_in_days = 7

  tags = {
    Name = "dr-rds-replica-key"
  }
}

resource "aws_kms_alias" "replica_encryption_key_alias" {
  name          = "alias/dr-rds-replica-key"
  target_key_id = aws_kms_key.replica_encryption_key.key_id
}