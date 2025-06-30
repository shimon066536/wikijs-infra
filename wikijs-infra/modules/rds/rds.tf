data "aws_secretsmanager_secret_version" "db_user" {
  secret_id = var.db_user_arn
}

data "aws_secretsmanager_secret_version" "db_pass" {
  secret_id = var.db_pass_arn
}

resource "aws_db_subnet_group" "wikijs" {
  name       = "wikijs-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "wikijs-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "wikijs_pg_params" {
  name        = "wikijs-pg-no-ssl"
  family      = "postgres17"
  description = "Disable SSL for Wiki.js testing"

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }

  tags = {
    Name = "wikijs-db-params"
  }
}

resource "aws_db_instance" "wikijs" {
  identifier         = "wikijs-db"
  engine             = "postgres"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = data.aws_secretsmanager_secret_version.db_user.secret_string
  password           = data.aws_secretsmanager_secret_version.db_pass.secret_string
  db_name            = "wikijs"
  port               = 5432
  parameter_group_name = aws_db_parameter_group.wikijs_pg_params.name

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.wikijs.name

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "wikijs-db"
  }
}