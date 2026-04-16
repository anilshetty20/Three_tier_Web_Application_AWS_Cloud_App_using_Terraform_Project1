module "vpc" {
  source = "./modules/vpc"
  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

module "security_group" {
  source = "./modules/security-group"

  vpc_id = module.vpc.vpc_id
}
module "rds" {
  source = "./modules/rds"

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  private_subnets = module.vpc.private_subnets
  rds_sg_id       = module.security_group.rds_sg_id
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
  alb_sg_id      = module.security_group.alb_sg_id
}


module "asg" {
  source = "./modules/asg"

  private_subnets  = module.vpc.private_subnets
  ec2_sg_id        = module.security_group.ec2_sg_id
  target_group_arn = module.alb.target_group_arn

  docker_image = var.docker_image
  db_endpoint = module.rds.db_host
  db_password  = var.db_password
  db_name = var.db_name
}

module "frontend" {
  source = "./modules/frontend"

  bucket_name  = "cloud-frontend-bucket-terraform"
  alb_dns_name = module.alb.alb_dns_name
}
