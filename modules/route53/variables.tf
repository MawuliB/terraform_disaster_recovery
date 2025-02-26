variable "hosted_zone_id" {
  description = "The Route 53 hosted zone ID"
  type        = string
}

variable "domain_name" {
  description = "The DNS name (e.g., example.com) for the record"
  type        = string
}

variable "primary_alb_dns" {
  description = "DNS name of the primary region ALB"
  type        = string
}

variable "primary_alb_zone_id" {
  description = "Zone ID of the primary region ALB"
  type        = string
}

variable "secondary_alb_dns" {
  description = "DNS name of the secondary region ALB"
  type        = string
}

variable "secondary_alb_zone_id" {
  description = "Zone ID of the secondary region ALB"
  type        = string
}

variable "primary_fqdn" {
  description = "The FQDN to be health checked (usually primary ALB or endpoint)"
  type        = string
}

variable "health_check_port" {
  description = "Port for the health check"
  type        = number
  default     = 80
}

variable "health_check_type" {
  description = "Type of health check (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "Interval in seconds between health checks"
  type        = number
  default     = 30
}

variable "health_check_failure_threshold" {
  description = "Number of consecutive failures required for an unhealthy status"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
