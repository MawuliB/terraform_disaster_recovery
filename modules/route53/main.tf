# Health Check for the primary region endpoint
resource "aws_route53_health_check" "primary" {
  fqdn              = var.primary_fqdn      # Primary ALB DNS name or domain name
  port              = var.health_check_port # 80 or 443
  type              = var.health_check_type # "HTTP" or "HTTPS"
  request_interval  = var.health_check_interval
  failure_threshold = var.health_check_failure_threshold

  tags = var.tags
}

# Primary failover record (active when healthy)
resource "aws_route53_record" "primary_failover" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.primary_alb_dns
    zone_id                = var.primary_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "primary"
  failover_routing_policy {
    type = "PRIMARY"
  }
  health_check_id = aws_route53_health_check.primary.id
}

# Secondary failover record (active when primary fails)
resource "aws_route53_record" "secondary_failover" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.secondary_alb_dns
    zone_id                = var.secondary_alb_zone_id
    evaluate_target_health = true
  }

  set_identifier = "secondary"
  failover_routing_policy {
    type = "SECONDARY"
  }
}
