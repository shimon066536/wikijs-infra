resource "aws_db_subnet_group" "wikijs" {
  name       = "wikijs-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "wikijs-db-subnet-group"
  }
}

resource "aws_db_instance" "wikijs" {
  identifier         = "wikijs-db"
  engine             = "postgres"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = local.db_credentials.username
  password           = local.db_credentials.password
  db_name            = "wikijs"
  port               = 5432

  vpc_security_group_ids = [var.db_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.wikijs.name

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "wikijs-db"
  }
}

locals {
  db_credentials = jsondecode(var.db_credentials_json)
}
