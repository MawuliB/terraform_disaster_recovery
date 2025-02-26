output "health_check_id" {
  description = "The ID of the Route 53 health check"
  value       = aws_route53_health_check.primary.id
}

output "primary_record_fqdn" {
  description = "The primary failover record FQDN"
  value       = aws_route53_record.primary_failover.fqdn
}

output "secondary_record_fqdn" {
  description = "The secondary failover record FQDN"
  value       = aws_route53_record.secondary_failover.fqdn
}