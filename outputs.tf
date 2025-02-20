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