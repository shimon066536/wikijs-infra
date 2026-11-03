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

variable "acm_certificate_arn" {
  description = "Issued ACM certificate ARN for the public HTTPS listener"
  type        = string
}

variable "app_domain_name" {
  description = "Public DNS hostname covered by the ACM certificate"
  type        = string
}
