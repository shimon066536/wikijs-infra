# Wiki.js Infrastructure on AWS

Terraform-based infrastructure for [Wiki.js](https://wiki.js.org/), built as a hands-on AWS/DevOps portfolio project and originally developed for a technical hiring assessment.

> **Project status:** Terraform formatting/validation, Trivy IaC scanning, and Gitleaks scanning pass in GitHub Actions on the hardening branch. The infrastructure and S3 backend bootstrap have **not** been deployed or integration-tested in AWS as part of this hardening work. A green CI run is not proof of production readiness.

## Architecture

```text
Internet users
    | HTTPS :443 (HTTP :80 redirects to HTTPS)
    v
Public Application Load Balancer
    | HTTP :3000 (TLS terminates at ALB)
    v
Wiki.js on ECS Fargate (private subnets)
    | PostgreSQL :5432 (SSL configured)
    v
Amazon RDS for PostgreSQL (private subnets)
```

| Component | Implementation |
| --- | --- |
| Infrastructure as Code | Terraform modules with AWS provider |
| Networking | VPC, two public and two private subnets across two available AZs in the selected region; Internet Gateway, NAT Gateway, route tables |
| Load balancing | Internet-facing ALB; HTTP-to-HTTPS redirect; ACM certificate supplied as an input |
| Application | Wiki.js container on ECS Fargate, one desired task |
| Database | Encrypted RDS PostgreSQL 17, private access, SSL enforcement configured |
| Secrets | RDS-managed master credentials in AWS Secrets Manager, injected into ECS at task start |
| Access control | IAM ECS task execution role and scoped Security Group ingress/egress |
| Observability | ECS application logs in CloudWatch Logs (7-day retention configured) |
| Supporting networking | Interface VPC endpoints for CloudWatch Logs and Secrets Manager with private DNS enabled |
| Terraform state | Optional S3 backend using SSE-S3, versioning, public-access blocking, and S3 lockfile |
| Credential rotation recovery | EventBridge `AWSCURRENT` event → Step Functions → ECS `ForceNewDeployment` (configured but not runtime-tested) |

**TLS boundary:** Client-to-ALB traffic uses HTTPS; ALB-to-ECS traffic is HTTP inside the VPC. Database SSL is configured but has not been verified with a running Wiki.js deployment.

The application image is pinned to **Wiki.js 2.5.314** using the published multi-platform OCI digest (`requarks/wiki:2.5.314@sha256:68f0d1848261ae76492ba358e30a96a76fed5d97a3fff381656082bf90f70d7e`). Update this pin deliberately after reviewing release notes and testing. The Trivy CI container is also pinned to a verified 0.76.1 digest.

## Repository layout

```text
.
├── .github/workflows/terraform-ci.yml
├── bootstrap/state-backend/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── modules/
│   ├── alb/
│   ├── ecs/
│   ├── iam/
│   ├── rds/
│   ├── security/
│   └── vpc/
├── backend.tf
├── backend.hcl.example
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── rotation.tf
└── README.md
```

There is **no longer a separate `modules/secrets` module**; the RDS instance manages its master secret.

## Local validation (no AWS resources created)

From the repository root, with Terraform installed:

```bash
terraform init -backend=false -input=false -lockfile=readonly
terraform fmt -check -recursive
terraform validate

terraform -chdir=bootstrap/state-backend init -backend=false -input=false -lockfile=readonly
terraform -chdir=bootstrap/state-backend validate
```

These commands initialize providers and check static configuration without activating the remote backend or provisioning AWS infrastructure. They do **not** establish whether an authenticated `terraform plan` or `apply` would succeed.

## Remote Terraform state (not provisioned)

The root `backend.tf` contains a partial S3 backend configuration:

- State key: `wikijs-infra/terraform.tfstate`
- Server-side encryption enabled
- Native S3 lockfile enabled with `use_lockfile = true`

A separate module at `bootstrap/state-backend/` defines the S3 bucket, versioning, default SSE-S3 (AES256) encryption, and S3 public-access blocking. **Having the configuration in Git does not mean the bucket exists.**

To enable remote state in a future AWS deployment:

1. Review the bootstrap module, target AWS account/region, expected charges, and handling of its **own local bootstrap state**. Decide whether to provision the bucket; this has not been done here.
2. Only after the bucket exists, copy `backend.hcl.example` to the ignored local file `backend.hcl` and replace its placeholder bucket name and region with the actual values.
3. From the repository root, initialize using `terraform init -backend-config=backend.hcl` with appropriate AWS credentials. If an existing state needs migration, **back it up and review the migration first**; do not overwrite or discard state.

Do not commit `backend.hcl`, `*.tfstate`, `*.tfvars`, credentials, or plan files. The repository's `.gitignore` excludes local Terraform state and variable files.

## Requirements for a future deployment

A deployment has **not** been performed or tested by the current CI pipeline. Before attempting one:

- Supply root variables `region`, `app_domain_name`, and `acm_certificate_arn`. The inputs `name` and `db_username` have defaults.
- Use a real DNS name and an **issued ACM certificate in the same AWS region as the ALB**; arrange the DNS record pointing to the ALB. This Terraform configuration does not create the domain or ACM certificate.
- Confirm the AWS account and region, an available backend bucket if using remote state, permissions, quotas, resource pricing, and cleanup plan.
- The VPC uses `aws_availability_zones` to select the first two available AZs **in the configured region**, assigning matching public/private subnets to each. A region must offer at least two usable AZs; the topology and capacity need confirmation at deployment.
- Run an authenticated `terraform plan` and review all proposed changes before considering `terraform apply`; neither step is validated in CI.

**Cost warning:** ALB, NAT Gateway, interface VPC endpoints, ECS Fargate, RDS, EventBridge, Step Functions, and related services can incur AWS charges. Local validation and GitHub Actions static checks do not create these resources.

## Continuous integration

The [Terraform CI workflow](.github/workflows/terraform-ci.yml) runs for pushes to `main` and `harden/**`, pull requests targeting `main`, and manual dispatch. It contains three jobs:

1. **Format and Validate:** Terraform formatting; provider initialization without the backend; root and bootstrap validation.
2. **Trivy IaC Security Scan:** HIGH/CRITICAL Terraform configuration findings, via a version- and digest-pinned official container image.
3. **Gitleaks Secret Scan:** scans Git history for potential committed secrets.

The workflow performs **no `terraform plan`, `apply`, or AWS deployment**. Gitleaks passing does not prove that credentials have never been exposed; previously exposed credentials must be rotated if they remain active.

## Security decisions and accepted risks

Hardening measures in the code include HTTPS at the ALB, a private RDS instance with storage encryption and configured SSL enforcement, RDS-managed Secrets Manager credentials, reduced outbound Security Group permissions, and an encrypted/versioned S3 backend definition.

Three resource-scoped Trivy suppressions are intentional and documented in Terraform:

| Trivy rule | Resource | Reason and remaining risk |
| --- | --- | --- |
| `AWS-0053` | Internet-facing ALB | Public access is intentional. Port 80 redirects to HTTPS on 443; public exposure remains by design. |
| `AWS-0104` | ECS task Security Group | Outbound TCP 443 to any IPv4 destination is currently needed for public image pulls and external HTTPS APIs through NAT; destinations remain unrestricted. |
| `AWS-0132` | S3 state-bucket encryption | SSE-S3 (AES256) is used for the cost-conscious portfolio backend. A customer-managed KMS key would provide additional key controls but has not been configured. |

These suppressions represent **documented risk acceptance, not remediation** of the underlying findings.

## Known limitations and next improvements

- **Runtime not verified:** no AWS apply, end-to-end application test, database TLS verification, DNS/ACM integration test, or recovery test has been completed in this hardening phase.
- **Database:** currently single-AZ with `skip_final_snapshot = true`. Configure appropriate backups, deletion safeguards, and recovery policy before production; using the RDS master account for the application should also be revisited.
- **Networking:** reduce ECS outbound destinations further (for example, a controlled image registry/ECR path and private endpoints). VPC endpoint private DNS and region-derived AZs are configured but not deployment-tested.
- **Application delivery:** images are pinned by digest; assess updates regularly, confirm health-check behavior, and test deployment sequencing.
## RDS password rotation and ECS refresh

RDS manages the database master secret and rotates it by default about every seven days. ECS resolves the injected database password when a task starts; an already-running task **does not automatically receive the rotated password**.

`rotation.tf` defines a scoped, event-driven refresh:

1. Secrets Manager publishes the native `Secret Label Updated` event when `AWSCURRENT` moves to a new version.
2. An EventBridge rule matches **only the specific RDS-managed secret ARN** and the `AWSCURRENT` label.
3. EventBridge starts an AWS Step Functions Standard workflow using a limited IAM role.
4. The workflow waits 30 seconds then calls `ecs:UpdateService` with `ForceNewDeployment = true`. Its IAM role is limited to that ECS service.

The workflow neither reads nor logs the password. It does not guarantee zero downtime, especially with a single ECS task. Event delivery, IAM permissions, database readiness, actual task replacement, and operational alerts still require validation in AWS. If an event is missed or automation fails, manually force a new ECS deployment, check CloudWatch/ECS logs, and confirm healthy database connectivity. Do not rotate a live database without an application recovery plan.

- **Availability and operations:** add appropriate autoscaling, alerts, cost controls, and infrastructure lifecycle procedures according to real workload requirements.
- **State operations:** confirm remote backend initialization, locking, bootstrap-state preservation, and state recovery in an authorized AWS environment.

The intent is to demonstrate reviewable Terraform and security trade-offs, **not** to claim a production-ready deployment without operational evidence.

---

**Contact:** shimon066536@gmail.com · [LinkedIn](https://www.linkedin.com/in/shimon-devops-growth/)
