output "db_endpoint" {
  value = aws_db_instance.wikijs.endpoint
}

output "db_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.wikijs.address
}