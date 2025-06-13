module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source              = "./modules/rds"
  private_subnet_ids  = module.vpc.private_subnet_ids
  db_sg_id            = module.security.rds_sg_id
  db_credentials_json = var.db_credentials_json
}


module "iam" {
  source = "./modules/iam"
}


module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.vpc.vpc_id
  alb_sg_id      = module.security.alb_sg_id
  public_subnets = module.vpc.public_subnet_ids
}

module "secrets" {
  source            = "./modules/secrets"
  secret_name       = "wikijs-db-secret-iac-v2"
  db_credentials_json  = var.db_credentials_json
}

module "ecs" {
  source = "./modules/ecs"

  name               = "wikijs"
  image              = "requarks/wiki:2"
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn

  private_subnets    = module.vpc.private_subnet_ids
  service_sg         = module.security.ecs_tasks_sg_id
  target_group_arn   = module.alb.target_group_arn
  alb_listener       = module.alb.listener_arn

  db_host            = module.rds.db_address
  db_credentials_json = var.db_credentials_json
}

