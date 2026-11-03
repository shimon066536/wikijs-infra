variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "wikijs_admin"
}

variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "wikijs"
}