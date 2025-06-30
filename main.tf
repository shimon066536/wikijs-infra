module "vpc" {
  source               = "./modules/vpc"
  region               = var.region
  security_group_ids   = module.security.security_group_ids
}

module "security" {
  source               = "./modules/security"
  vpc_id               = module.vpc.vpc_id
  private_subnet_cidrs = module.vpc.private_subnet_cidrs
}

module "iam" {
  source               = "./modules/iam"
  db_user_arn          = module.secrets.db_user_arn
  db_pass_arn          = module.secrets.db_pass_arn
}

module "alb" {
  source               = "./modules/alb"
  vpc_id               = module.vpc.vpc_id
  alb_sg_id            = module.security.alb_sg_id
  public_subnets       = module.vpc.public_subnet_ids
}

module "secrets" {
  source               = "./modules/secrets"
  db_username          = var.db_username
  db_password          = var.db_password
}

module "rds" {
  source               = "./modules/rds"
  private_subnet_ids   = module.vpc.private_subnet_ids
  db_sg_id             = module.security.rds_sg_id
  db_user_arn          = module.secrets.db_user_arn
  db_pass_arn          = module.secrets.db_pass_arn
  depends_on           = [module.secrets]
}

module "ecs" {
  source = "./modules/ecs"
  name                 = var.name
  image                = "requarks/wiki:latest"
  execution_role_arn   = module.iam.ecs_task_execution_role_arn
  private_subnets      = module.vpc.private_subnet_ids
  service_sg           = module.security.ecs_tasks_sg_id
  target_group_arn     = module.alb.target_group_arn
  alb_listener         = module.alb.listener_arn
  region               = var.region
  db_host              = module.rds.db_host
  db_user_arn          = module.secrets.db_user_arn
  db_pass_arn          = module.secrets.db_pass_arn
}