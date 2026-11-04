mock_provider "aws" {}

run "private_tasks_with_secret_references" {
  command = plan
  module {
    source = "./modules/ecs"
  }
  variables {
    name               = "wikijs-test"
    image              = "requarks/wiki:test"
    execution_role_arn = "arn:aws:iam::123456789012:role/test"
    private_subnets    = ["subnet-12345678", "subnet-87654321"]
    service_sg         = "sg-12345678"
    target_group_arn   = "arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/test/1234567890123456"
    db_host            = "test.example.invalid"
    region             = "eu-west-1"
    db_secret_arn      = "arn:aws:secretsmanager:eu-west-1:123456789012:secret:test-AbCdEf"
  }
  assert {
    condition     = !aws_ecs_service.wiki.network_configuration[0].assign_public_ip
    error_message = "Application tasks must not have public IPs."
  }
  assert {
    condition     = jsondecode(aws_ecs_task_definition.wiki.container_definitions)[0].secrets[1].valueFrom == "${var.db_secret_arn}:password::"
    error_message = "The password must be injected by reference at task startup."
  }
  assert {
    condition     = aws_ecs_service.wiki.deployment_circuit_breaker[0].rollback
    error_message = "Failed deployments must enable rollback."
  }
}
