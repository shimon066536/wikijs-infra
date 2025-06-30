resource "aws_secretsmanager_secret" "db_user" {
  name          = "wikijs-db-user-v5"
}

resource "aws_secretsmanager_secret_version" "db_user_version" {
  secret_id     = aws_secretsmanager_secret.db_user.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_pass" {
  name          = "wikijs-db-pass-v5"
}

resource "aws_secretsmanager_secret_version" "db_pass_version" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = var.db_password
}