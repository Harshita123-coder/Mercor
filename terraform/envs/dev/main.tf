terraform {
  required_version = ">= 1.0.0"
  required_providers { 
    aws = { 
      source  = "hashicorp/aws"
      version = "~> 5.50" 
    } 
  }
}

provider "aws" { 
  region = var.region 
}

module "network" {
  source              = "../../modules/network"
  name_prefix         = var.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnets
}

module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = var.name_prefix
  repo_name   = var.ecr_repo_name
}

module "traffic" {
  source      = "../../modules/traffic"
  name_prefix = var.name_prefix
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.public_subnet_ids
  port        = var.container_port
  health_path = var.health_path
}

module "cluster" {
  source      = "../../modules/cluster"
  name_prefix = var.name_prefix
}

module "compute" {
  source           = "../../modules/compute"
  name_prefix      = var.name_prefix
  subnet_ids       = module.network.public_subnet_ids
  vpc_id           = module.network.vpc_id
  cluster_name     = module.cluster.cluster_name
  instance_type    = var.instance_type
  desired          = var.desired_capacity
  max              = var.max_capacity
  ami_id           = var.ami_id
  container_port   = var.container_port
  alb_sg_id        = module.traffic.alb_sg_id
}

module "ecs_service" {
  source         = "../../modules/ecs_service"
  name_prefix    = var.name_prefix
  cluster_id     = module.cluster.cluster_id
  cluster_name   = module.cluster.cluster_name
  repo_url       = module.ecr.repository_url
  container_port = var.container_port
  region         = var.region
  tg_blue_arn    = module.traffic.tg_blue_arn
}

module "codedeploy" {
  source          = "../../modules/codedeploy"
  name_prefix     = var.name_prefix
  cluster_name    = module.cluster.cluster_name
  service_name    = module.ecs_service.service_name
  listener_arn    = module.traffic.listener_arn
  tg_blue_name    = module.traffic.tg_blue_name
  tg_green_name   = module.traffic.tg_green_name
}

output "alb_dns" { 
  value = module.traffic.alb_dns 
}

output "codedeploy_app" { 
  value = module.codedeploy.application_name 
}

output "codedeploy_deploy_group" { 
  value = module.codedeploy.deployment_group_name 
}

output "task_exec_role_arn" { 
  value = module.ecs_service.task_exec_role_arn 
}

output "cluster_name" { 
  value = module.cluster.cluster_name 
}

output "service_name" { 
  value = module.ecs_service.service_name 
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
