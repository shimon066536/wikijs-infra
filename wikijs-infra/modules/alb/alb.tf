resource "aws_lb" "wikijs_alb" {
  name                  = "wikijs-alb"
  internal              = false
  load_balancer_type    = "application"
  security_groups       = [var.alb_sg_id]
  subnets               = var.public_subnets

  enable_deletion_protection = false

  tags                  = {
    Name                = "wikijs-alb"
  }
}

resource "aws_lb_target_group" "wikijs_tg" {
  name                  = "wikijs-tg"
  port                  = 3000
  protocol              = "HTTP"
  vpc_id                = var.vpc_id
  target_type           = "ip"

  health_check {
    path                = "/"
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
  load_balancer_arn    = aws_lb.wikijs_alb.arn
  port                 = 80
  protocol             = "HTTP"

  default_action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.wikijs_tg.arn
  }
}