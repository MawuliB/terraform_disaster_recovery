resource "aws_db_instance" "read_replica" {
  replicate_source_db  = var.source_db_instance_identifier
  instance_class       = var.instance_class
  identifier           = var.identifier
  engine               = var.engine
  engine_version       = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible  = false
  tags                 = var.tags
}

resource "aws_db_subnet_group" "default" {
  name       = "dr-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "DR DB Subnet Group"
  }
}
