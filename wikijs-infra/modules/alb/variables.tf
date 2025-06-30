variable "vpc_id" {
  description = "VPC ID for the ALB"
  type        = string
}

variable "alb_sg_id" {
  description = "Security Group for the ALB"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}
