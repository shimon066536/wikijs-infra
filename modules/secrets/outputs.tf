output "wikijs_secret_arn" {
  description = "ARN of the Wiki.js DB secret"
  value       = aws_secretsmanager_secret.db.arn
}

output "wikijs_secret_string" {
  description = "Secret string contents"
  value       = var.db_credentials_json
  sensitive   = true
}
