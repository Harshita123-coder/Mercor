output "alb_dns" {
  description = "DNS name of the load balancer"
  value       = module.traffic.alb_dns
}

output "codedeploy_app" {
  description = "CodeDeploy application name"
  value       = try(module.codedeploy.app_name, "mercor-demo-cd-app")
}

output "codedeploy_deploy_group" {
  description = "CodeDeploy deployment group name"  
  value       = try(module.codedeploy.deployment_group, "mercor-demo-dg")
}

output "task_exec_role_arn" {
  description = "Task execution role ARN"
  value       = module.ecs_service.task_exec_role_arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = module.cluster.cluster_name
}

output "service_name" {
  description = "ECS service name"
  value       = module.ecs_service.service_name
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecr.repository_url
}