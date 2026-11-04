variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "allowed_client_cidrs" {
  description = "IPv4 CIDRs allowed to reach the ALB. Restrict to the operator during initial Wiki.js setup."
  type        = list(string)

  validation {
    condition     = length(var.allowed_client_cidrs) > 0 && alltrue([for cidr in var.allowed_client_cidrs : can(cidrnetmask(cidr))])
    error_message = "Supply at least one valid IPv4 CIDR."
  }
}
