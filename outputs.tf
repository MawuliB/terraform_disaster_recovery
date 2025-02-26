output "vpc_primary_id" {
  value = module.vpc_primary.vpc_id
}

output "vpc_secondary_id" {
  value = module.vpc_secondary.vpc_id
}

output "elb_primary_dns_name" {
  value = module.elb_primary.alb_dns_name
}

output "elb_secondary_dns_name" {
  value = module.elb_secondary.alb_dns_name
}

output "primary_record_fqdn" {
  value = module.route53_failover.primary_record_fqdn
}

output "secondary_record_fqdn" {
  value = module.route53_failover.secondary_record_fqdn
}