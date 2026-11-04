# Internet-facing ALB is intentional for this public Wiki.js application.
# HTTPS is served on port 443; HTTP on port 80 redirects to HTTPS.
# trivy:ignore:AWS-0053
resource "aws_lb" "wikijs_alb" {
  name                       = "wikijs-alb"
  internal                   = false
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "wikijs-alb"
  }
}

resource "aws_lb_target_group" "wikijs_tg" {
  name        = "wikijs-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "wikijs-tg"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.wikijs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.wikijs_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wikijs_tg.arn
  }
}
