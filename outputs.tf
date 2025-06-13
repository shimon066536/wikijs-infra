output "wiki_url" {
  description = "Public URL of the Wiki.js application"
  value       = "http://${module.alb.lb_dns_name}"
}
