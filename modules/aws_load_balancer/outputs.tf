output "target_group" {
  value = aws_lb_target_group.target_group
}

output "dns_name" {
  value = aws_alb.application_load_balancer.dns_name
}
