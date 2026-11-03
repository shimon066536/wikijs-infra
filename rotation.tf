# RDS-managed master credentials rotate automatically (every 7 days by default).
# ECS injects Secrets Manager values only at task startup; running tasks do not
# receive a new password automatically. Redeploy the ECS service when AWSCURRENT
# moves to a new secret version, without exposing credentials in Terraform state.
#
# Secrets Manager publishes native Secret Label Updated events in EventBridge.
# The event pattern is scoped to the exact RDS-managed secret ARN.

resource "aws_cloudwatch_event_rule" "rds_secret_current_updated" {
  name        = "${var.name}-rds-secret-rotated"
  description = "Redeploy Wiki.js ECS tasks after the RDS-managed secret's AWSCURRENT label moves"

  event_pattern = jsonencode({
    source        = ["aws.secretsmanager"]
    "detail-type" = ["Secret Label Updated"]
    resources     = [module.rds.db_secret_arn]
    detail = {
      labelUpdated = ["AWSCURRENT"]
    }
  })
}

resource "aws_iam_role" "ecs_rotation_state_machine" {
  name = "${var.name}-ecs-rotation-state-machine"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "states.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "ecs_rotation_state_machine" {
  name = "update-wikijs-ecs-service"
  role = aws_iam_role.ecs_rotation_state_machine.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ecs:UpdateService"]
      Resource = [module.ecs.service_arn]
    }]
  })
}

resource "aws_sfn_state_machine" "ecs_rotation_redeploy" {
  name     = "${var.name}-ecs-rotation-redeploy"
  role_arn = aws_iam_role.ecs_rotation_state_machine.arn
  type     = "STANDARD"

  definition = jsonencode({
    Comment = "Force a new ECS deployment after the DB secret AWSCURRENT version changes"
    StartAt = "AllowSecretPropagation"
    States = {
      AllowSecretPropagation = {
        Type    = "Wait"
        Seconds = 30
        Next    = "ForceNewDeployment"
      }
      ForceNewDeployment = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:ecs:updateService"
        Parameters = {
          Cluster            = module.ecs.cluster_name
          Service            = module.ecs.service_name
          ForceNewDeployment = true
        }
        ResultPath = null
        Retry = [{
          ErrorEquals     = ["States.TaskFailed"]
          IntervalSeconds = 10
          MaxAttempts     = 3
          BackoffRate     = 2
        }]
        End = true
      }
    }
  })

  depends_on = [aws_iam_role_policy.ecs_rotation_state_machine]
}

resource "aws_iam_role" "eventbridge_start_rotation_workflow" {
  name = "${var.name}-start-ecs-rotation-workflow"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "events.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_start_rotation_workflow" {
  name = "start-wikijs-rotation-state-machine"
  role = aws_iam_role.eventbridge_start_rotation_workflow.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["states:StartExecution"]
      Resource = [aws_sfn_state_machine.ecs_rotation_redeploy.arn]
    }]
  })
}

resource "aws_cloudwatch_event_target" "rds_secret_rotation" {
  rule      = aws_cloudwatch_event_rule.rds_secret_current_updated.name
  target_id = "WikiJsEcsRotationRedeploy"
  arn       = aws_sfn_state_machine.ecs_rotation_redeploy.arn
  role_arn  = aws_iam_role.eventbridge_start_rotation_workflow.arn

  depends_on = [aws_iam_role_policy.eventbridge_start_rotation_workflow]
}
