resource "aws_secretsmanager_secret" "db" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = var.db_credentials_json
}
