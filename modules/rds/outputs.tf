output "db_endpoint" {
  value = aws_db_instance.wikijs.endpoint
}

output "db_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.wikijs.address
}

output "db_secret_arn" {
  description = "ARN of the RDS-managed master secret"
  value       = aws_db_instance.wikijs.master_user_secret[0].secret_arn
}