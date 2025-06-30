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
  type = string
  description = "RDS address (endpoint)"
}
variable "db_port" {
  type    = number
  default = 5432
  description = "Port of the database"
}
variable "db_type" {
  type    = string
  default = "postgres"
  description = "Type of the database (e.g. postgres)"
}
variable "db_name" {
  type    = string
  default = "wikijs"
  description = "Name of the database"
}
variable "db_user_arn" {
  type    = string
  description = "ARN of the Secrets Manager secret used by the ECS Task"
}
variable "db_pass_arn" {
  type    = string
  description = "ARN of the Secrets Manager secret used by the ECS Task"
}
variable "region" {
  type    = string
  description = "ARN of the Secrets Manager secret used by the ECS Task"
}