output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.read_replica.id
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.read_replica.endpoint
}