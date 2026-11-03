variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "wikijs_admin"
}