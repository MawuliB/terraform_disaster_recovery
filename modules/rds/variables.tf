variable "allocated_storage" {
  description = "The allocated storage in GB."
  type        = number
  default     = 20
}

variable "engine" {
  description = "The database engine (e.g., mysql, postgres)."
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The version of the database engine."
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "identifier" {
  description = "The identifier for the RDS instance."
  type        = string
}

variable "username" {
  description = "The master username for the RDS instance."
  type        = string
}

variable "parameter_group_name" {
  description = "The name of the DB parameter group."
  type        = string
  default     = ""
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs for the DB instance."
  type        = list(string)
}

variable "multi_az" {
  description = "Whether to deploy a multi-AZ RDS instance."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the DB instance."
  type        = map(string)
  default     = {}
}

variable "db_subnet_ids" {
  description = "A list of DB subnet IDs."
  type        = list(string)
}