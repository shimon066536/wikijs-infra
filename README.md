# OpsGuru Hiring Assessment – Wiki.js Infrastructure

##  Problem
Build a secure, scalable, observable, and automated cloud infrastructure for Wiki.js using IaC.

##  Solution Highlights
- **Cloud**: AWS
- **IaC**: Terraform (modular)
- **Compute**: ECS Fargate
- **DB**: RDS PostgreSQL
- **Secrets**: AWS Secrets Manager
- **Monitoring**: CloudWatch Logs
- **Security**: Scoped Security Groups, IAM roles
- **Scaling**: ECS service with ALB target  Structure
- `modules/` – Reusable Terraform modules (vpc, alb, rds, ecs, iam, security, secrets)
- `main.tf` – Composition of modules
- `terraform.tfvars` – Secrets/parameters
- `outputs.tf` – Useful outputs like ALB URL

##  Security Considerations
- Secrets stored in AWS Secrets Manager
- ALB Security Group limited to ports 80/443
- RDS only accessible from ECS tasks
- IAM roles per best practices

##  Setup
```bash
terraform init
terraform apply -var-file="terraform.tfvars"
