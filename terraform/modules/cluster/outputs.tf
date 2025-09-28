output "cluster_id"   { value = aws_ecs_cluster.cluster.id }
output "cluster_name" { value = aws_ecs_cluster.cluster.name }
output "log_group"    { value = aws_cloudwatch_log_group.lg.name }
