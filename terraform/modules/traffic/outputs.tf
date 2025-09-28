output "alb_dns"        { value = aws_lb.alb.dns_name }
output "listener_arn"   { value = aws_lb_listener.http.arn }
output "tg_blue_arn"    { value = aws_lb_target_group.blue.arn }
output "tg_blue_name"   { value = aws_lb_target_group.blue.name }
output "tg_green_arn"   { value = aws_lb_target_group.green.arn }
output "tg_green_name"  { value = aws_lb_target_group.green.name }
output "alb_sg_id"      { value = aws_security_group.alb.id }
