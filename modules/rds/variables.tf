variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "db_user_arn" {
  type    = string
  description = "ARN of the Secrets Manager secret"
}

variable "db_pass_arn" {
  type    = string
  description = "ARN of the Secrets Manager secret"
}