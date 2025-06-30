output "db_user_arn" {
  value = aws_secretsmanager_secret.db_user.arn
}

output "db_pass_arn" {
  value = aws_secretsmanager_secret.db_pass.arn
}

output "db_user" {
  value = aws_secretsmanager_secret_version.db_user_version.secret_string
}

output "db_pass" {
  value = aws_secretsmanager_secret_version.db_pass_version.secret_string
}
