mock_provider "aws" {}

run "private_managed_database" {
  command = plan
  module {
    source = "./modules/rds"
  }
  variables {
    private_subnet_ids = ["subnet-12345678", "subnet-87654321"]
    db_sg_id           = "sg-12345678"
  }
  assert {
    condition     = aws_db_instance.wikijs.storage_encrypted && !aws_db_instance.wikijs.publicly_accessible && aws_db_instance.wikijs.manage_master_user_password
    error_message = "RDS must remain private, encrypted, and use managed credentials."
  }
  assert {
    condition     = anytrue([for p in aws_db_parameter_group.wikijs_pg_params.parameter : p.name == "rds.force_ssl" && p.value == "1"])
    error_message = "PostgreSQL must require TLS."
  }
}
