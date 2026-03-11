output "asg_name" {
  value       = aws_autoscaling_group.ASG_EC2.name
  description = "Auto Scaling Group name"
}

output "launch_template_id" {
  value       = aws_launch_template.test_server.id
  description = "Launch template ID"
}
