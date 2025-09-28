output "service_name" { 
  value = aws_ecs_service.svc.name 
}

output "task_exec_role_arn" { 
  value = aws_iam_role.task_exec.arn 
}

output "task_definition_arn" { 
  value = aws_ecs_task_definition.task.arn 
}

output "log_group" { 
  value = aws_cloudwatch_log_group.lg.name 
}
