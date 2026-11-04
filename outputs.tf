
output "wiki_url" {
  description = "Public HTTPS URL of the Wiki.js application"
  value       = "https://${var.app_domain_name}"
}

output "db_address" {
  description = "RDS endpoint URL"
  value       = module.rds.db_host
}
output "alb_dns_name" {
  description = "ALB hostname used to configure the application DNS record"
  value       = module.alb.lb_dns_name
}
