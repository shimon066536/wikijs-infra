variable "name" {
  description = "Base name for ECS cluster, task, and service"
  type        = string
}

variable "image" {
  description = "Docker image for the Wiki.js container"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM role ARN for ECS task execution (pulling image, logs, etc.)"
  type        = string
}

variable "task_role_arn" {
  description = "IAM role ARN for the task's runtime permissions"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnets for ECS networking"
  type        = list(string)
}

variable "service_sg" {
  description = "Security group ID for the ECS service tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group to register the ECS service"
  type        = string
}

variable "alb_listener" {
  description = "Dummy input used in depends_on to ensure LB readiness"
  type        = any
}

variable "db_host" {
  description = "Hostname or endpoint of the PostgreSQL RDS instance"
  type        = string
}

variable "db_credentials_json" {
  description = "JSON string with DB credentials (username/password)"
  type        = string
  sensitive   = true
}
