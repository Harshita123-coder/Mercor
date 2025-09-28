output "asg_arn" { 
  value = aws_autoscaling_group.asg.arn 
}

output "ecs_hosts_sg_id" { 
  value = aws_security_group.ecs_hosts.id 
}

output "capacity_provider_name" { 
  value = aws_ecs_capacity_provider.cp.name 
}
