mock_provider "aws" {}

run "https_and_application_health" {
  command = plan
  module {
    source = "./modules/alb"
  }
  variables {
    vpc_id              = "vpc-12345678"
    alb_sg_id           = "sg-12345678"
    public_subnets      = ["subnet-12345678", "subnet-87654321"]
    acm_certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  }
  assert {
    condition     = aws_lb_listener.http.default_action[0].redirect[0].protocol == "HTTPS" && aws_lb_listener.https.protocol == "HTTPS"
    error_message = "Public HTTP must redirect to an HTTPS listener."
  }
  assert {
    condition     = aws_lb_target_group.wikijs_tg.target_type == "ip" && aws_lb_target_group.wikijs_tg.health_check[0].path == "/healthz"
    error_message = "Fargate requires IP targets with an application health endpoint."
  }
}
