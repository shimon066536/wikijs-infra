variable "region" {
  type        = string
  description = "AWS region for the Terraform state bucket"
  default     = "eu-west-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform remote state"
}