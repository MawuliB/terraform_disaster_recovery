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

variable "password" {
  description = "The master password for the RDS instance."
  type        = string
  sensitive   = true
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

variable "source_db_instance_identifier" {
  description = "The identifier of the source DB instance for a read replica."
  type        = string
}

variable "db_subnet_ids" {
  description = "A list of DB subnet IDs for the DB subnet group."
  type        = list(string) 
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the DB instance"
  type        = bool
  default     = false
}

variable "is_read_replica" {
  description = "Whether the RDS instance is a read replica"
  type        = bool
  default     = true
  
}