# Wiki.js Infrastructure

## Overview

This project provisions a **secure, scalable, and observable cloud infrastructure** for deploying [Wiki.js](https://wiki.js.org/) using **Infrastructure as Code (IaC)** with Terraform on AWS.  
The goal is to demonstrate best practices in automation, security, and modular cloud architecture.

---

## 🛠️ Architecture Summary

| Component           | Technology                |
|--------------------|---------------------------|
| **Cloud Provider** | AWS                       |
| **IaC Tool**       | Terraform (modular setup) |
| **Compute**        | ECS Fargate               |
| **Database**       | RDS PostgreSQL            |
| **Secrets**        | AWS Secrets Manager       |
| **Networking**     | VPC with public/private subnets |
| **Load Balancer**  | Application Load Balancer (ALB) |
| **Monitoring**     | CloudWatch Logs           |
| **Security**       | IAM Roles, Scoped Security Groups |

---

## 📁 Repository Structure

<pre lang="markdown">
wikijs-infra/
├── modules/
│ ├── vpc/
│ ├── alb/
│ ├── rds/
│ ├── ecs/
│ ├── iam/
│ ├── security/
│ └── secrets/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── README.md
</pre>

Each module is self-contained and reusable, promoting maintainability and scalability.

---

## 🔐 Security Highlights

- All secrets (e.g., DB credentials) are securely stored in **AWS Secrets Manager**
- **IAM roles** are scoped using *least privilege* principles
- The **ALB** only allows inbound traffic on ports **80/443**
- **RDS** is not publicly accessible and is reachable only from ECS tasks within the private subnet
---

## 🚀 Deployment Instructions

### **Prerequisites:**
> - Terraform installed ([docs](https://developer.hashicorp.com/terraform/install))  
> - AWS credentials configured

```bash
terraform init
terraform validate
terraform plan -out=tfplan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

### To destroy the infrastructure:

```bash
terraform destroy -var-file="terraform.tfvars"
```

#### 📌 Notable Features
Fully modular Terraform design

Environment-agnostic (easily extendable for dev/staging/prod)

Clean separation of concerns between networking, compute, security, and secrets

Infrastructure can be deployed with a single command

#### 📊 Observability
Application and service logs are collected via CloudWatch Logs

ALB access logs can be enabled for traffic analysis

Ready for integration with Prometheus, Grafana, or AWS X-Ray

#### 📎 Additional Notes
Designed to be production-grade with minimal adjustments

Can be extended with CI/CD pipelines (e.g., GitHub Actions, Atlantis)

#### Recommended improvements:

Add autoscaling policies

WAF integration

Cost monitoring and tagging strategy

---
#### This project was developed as part of a technical hiring assessment.
---
Contact:
📧 shimon066536@gmail.com
🔗 [LinkedIn Profile](https://www.linkedin.com/in/shimon-devops-growth/)


## Security Scanning and Accepted Risks

GitHub Actions performs automated Terraform validation,
Trivy IaC security scanning, and Gitleaks secret scanning.

The following Trivy findings are explicitly documented
and suppressed at the relevant Terraform resources:

| Rule | Resource | Justification |
|------|----------|---------------|
| AWS-0053 | Public ALB | Intentional internet-facing entry point; HTTP redirects to HTTPS |
| AWS-0104 | ECS Security Group | Outbound HTTPS (TCP 443) is required for public container image pulls and external API access through NAT |
| AWS-0132 | S3 State Backend | SSE-S3 (AES256) is used to avoid the additional cost and complexity of a customer-managed KMS key |

### Security Trade-offs

- ECS outbound HTTPS destinations remain unrestricted.
  A future improvement is to use Amazon ECR, VPC endpoints,
  and tighter outbound network controls.
- The S3 backend configuration includes encryption,
  versioning, and public access blocking.
- Customer-managed KMS encryption can be introduced
  when additional key control is required.
- These exceptions represent documented risk acceptance,
  not the elimination of the underlying risks.
- This infrastructure has been validated statically.
  Deployment and runtime behavior have not yet been verified.

### Before Production Deployment

- Configure a real domain and issued ACM certificate.
- Review network egress and database access controls.
- Configure production-appropriate RDS backup and
  recovery settings.
- Review infrastructure costs and resource lifecycle.
- Perform an authenticated Terraform plan and
  integration tests in a controlled AWS environment.
