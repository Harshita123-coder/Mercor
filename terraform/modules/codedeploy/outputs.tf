output "application_name" { 
  value = aws_codedeploy_app.app.name 
}

output "deployment_group_name" { 
  value = aws_codedeploy_deployment_group.dg.deployment_group_name 
}
