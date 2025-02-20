
variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_cidr_blocks" {
  description = "List of CIDR blocks allowed to egress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
