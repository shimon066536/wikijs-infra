variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  type        = list(string)
}
