mock_provider "aws" {}

run "restricted_setup_access" {
  command = plan
  module {
    source = "./modules/security"
  }
  variables {
    vpc_id               = "vpc-12345678"
    private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
    allowed_client_cidrs = ["192.0.2.10/32"]
  }
  assert {
    condition     = alltrue([for rule in aws_security_group.alb_sg.ingress : rule.cidr_blocks == toset(["192.0.2.10/32"])])
    error_message = "Initial ALB access must stay restricted to the operator."
  }
  assert {
    condition     = alltrue([for rule in aws_security_group.rds_sg.ingress : rule.from_port == 5432 && length(rule.cidr_blocks) == 0])
    error_message = "Database ingress must use security groups and PostgreSQL only."
  }
}
