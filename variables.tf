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

variable "allowed_client_cidrs" {
  description = "IPv4 CIDRs allowed to reach the ALB. Restrict to the operator during initial Wiki.js setup."
  type        = list(string)

  validation {
    condition     = length(var.allowed_client_cidrs) > 0 && alltrue([for cidr in var.allowed_client_cidrs : can(cidrnetmask(cidr))])
    error_message = "Supply at least one valid IPv4 CIDR."
  }
}
