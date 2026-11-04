resource "aws_security_group" "alb_sg" {
  name        = "wikijs-alb-sg"
  description = "Allow HTTP/HTTPS traffic from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_client_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_client_cidrs
  }

  egress {
    description = "Allow HTTP traffic to ECS tasks"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  tags = {
    Name = "wikijs-alb-sg"
  }
}

# Security exception: public HTTPS egress is required for Docker Hub
# image pulls and external AWS API access through the NAT Gateway.
# Traffic is limited to TCP 443; destination IPs remain unrestricted.
# Reassess if migrating images to private ECR and VPC endpoints.
# trivy:ignore:AWS-0104
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "wikijs-ecs-tasks-sg"
  description = "Allow traffic from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # PostgreSQL access within private subnets
  egress {
    description = "PostgreSQL to RDS in private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # HTTPS access to AWS services and public container registries
  egress {
    description = "HTTPS to AWS services and Docker Hub via NAT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wikijs-ecs-tasks-sg"
  }
}


resource "aws_security_group" "rds_sg" {
  name        = "wikijs-rds-sg"
  vpc_id      = var.vpc_id
  description = "Allow PostgreSQL from ECS tasks only"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  tags = {
    Name = "wikijs-rds-sg"
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "vpc-endpoints-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}
