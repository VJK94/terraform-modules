output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "load_balancer_dns_name" {
  description = "The DNS name of the application load balancer"
  value       = aws_lb.app_lb.dns_name
}