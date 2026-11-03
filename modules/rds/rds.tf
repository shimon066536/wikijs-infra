resource "aws_db_subnet_group" "wikijs" {
  name       = "wikijs-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "wikijs-db-subnet-group"
  }
}

resource "aws_db_parameter_group" "wikijs_pg_params" {
  name        = "wikijs-pg-secure"
  family      = "postgres17"
  description = "Enforce SSL for PostgreSQL connections"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = {
    Name = "wikijs-db-params"
  }
}

resource "aws_db_instance" "wikijs" {
  identifier                  = "wikijs-db"
  engine                      = "postgres"
  engine_version              = "17"
  instance_class              = "db.t3.micro"
  allocated_storage           = 20
  username                    = var.db_username
  manage_master_user_password = true
  storage_encrypted           = true
  db_name                     = "wikijs"
  port                        = 5432
  parameter_group_name        = aws_db_parameter_group.wikijs_pg_params.name

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.wikijs.name

  multi_az            = false
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "wikijs-db"
  }
}