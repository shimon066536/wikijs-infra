resource "aws_ecs_cluster" "this" {
  name                          = "${var.name}-cluster"
}

resource "aws_ecs_task_definition" "wiki" {
  family                        = "${var.name}-task"
  requires_compatibilities      = ["FARGATE"]
  network_mode                  = "awsvpc"
  cpu                           = "512"
  memory                        = "1024"
  execution_role_arn            = var.execution_role_arn

  container_definitions         = jsonencode([
    {
      name                      = "wiki"
      image                     = var.image
      portMappings              = [
        {
          containerPort         = 3000
          hostPort              = 3000
        }
      ]
      logConfiguration          = {
        logDriver               = "awslogs"
        options                 = {
          awslogs-group         = aws_cloudwatch_log_group.wikijs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      environment               = [
        {
          name                  = "DB_TYPE"
          value                 = "postgres"
        },
        {
          name                  = "DB_HOST"
          value                 = var.db_host
        },
        {
          name                  = "DB_PORT"
          value                 = tostring(var.db_port)
        },
        {
          name                  = "DB_NAME"
          value                 = var.db_name
        }
      ]
      secrets                   = [
        {
          name                  = "DB_USER"
          valueFrom             = var.db_user_arn
        },
        {
          name                  = "DB_PASS"
          valueFrom             = var.db_pass_arn
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "wiki" {
  name                          = "${var.name}-svc"
  cluster                       = aws_ecs_cluster.this.id
  task_definition               = aws_ecs_task_definition.wiki.arn
  launch_type                   = "FARGATE"
  desired_count                 = 1

  network_configuration {
    subnets                     = var.private_subnets
    security_groups             = [var.service_sg]
    assign_public_ip            = false
  }

  load_balancer {
    target_group_arn            = var.target_group_arn
    container_name              = "wiki"
    container_port              = 3000
  }

  depends_on                    = [var.alb_listener]
}

resource "aws_cloudwatch_log_group" "wikijs" {
  name                          = "/ecs/${var.name}"
  retention_in_days             = 7

  tags                          = {
    Name                        = "wikijs-log-group"
  }
}
