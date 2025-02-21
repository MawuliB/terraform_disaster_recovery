output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = aws_db_instance.primary.id
}

output "db_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.primary.endpoint
}