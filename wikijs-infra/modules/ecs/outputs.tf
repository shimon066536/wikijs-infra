
output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.wiki.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.wiki.arn
}

output "log_group_name" {
  description = "CloudWatch log group name for the container"
  value       = aws_cloudwatch_log_group.wikijs.name
}

output "db_name" {
  value       = var.db_name
}

output "db_port" {
  value       = var.db_port
}
