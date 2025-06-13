variable "secret_name" {
  description = "The name of the secret"
  type        = string
}

variable "secret_description" {
  description = "A description of the secret"
  type        = string
  default     = "Credentials for Wiki.js RDS PostgreSQL"
}

variable "db_credentials_json" {
  description = "DB credentials as JSON string"
  type        = string
}
