output "alb_dns_name" {
  value = aws_lb.wikijs_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.wikijs_tg.arn
}

output "listener_arn" {
  value = aws_lb_listener.http.arn
}

output "lb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.wikijs_alb.dns_name
}
