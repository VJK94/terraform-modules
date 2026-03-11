#Create a launch template for Auto Scaling Group
resource "aws_launch_template" "test_server" {
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  network_interfaces {
    security_groups             = [var.security_group_id]
    associate_public_ip_address = true
  }

  # NOTE: DB credentials are passed via user data in plaintext.
  # In production, use AWS Secrets Manager instead.
  user_data = base64encode(templatefile("${path.module}/user_data1.sh", {
    LOAD_BALANCER_URL = var.lb_dns_name,
    APACHE_LOG_DIR    = "/var/log/apache2",
    rds_host          = var.rds_host
    username          = var.db_username
    password          = var.db_password
    db_name           = "${var.env}-terraform-db"
  }))
}

#Create a ASG and link the launch template
resource "aws_autoscaling_group" "ASG_EC2" {
  vpc_zone_identifier = var.public_subnet_ids
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  health_check_type   = "ELB"
  target_group_arns   = [var.target_group_arn]
  launch_template {
    id      = aws_launch_template.test_server.id
    version = "$Latest"
  }
}

# Tag 1
resource "aws_autoscaling_group_tag" "asg_name_tag" {
  autoscaling_group_name = aws_autoscaling_group.ASG_EC2.name

  tag {
    key                 = "Name"
    value               = "${var.env}_test_server"
    propagate_at_launch = true
  }
}

# Tag 2
resource "aws_autoscaling_group_tag" "asg_project_tag" {
  autoscaling_group_name = aws_autoscaling_group.ASG_EC2.name

  tag {
    key                 = "Project"
    value               = "${var.env}_asg_ec2_rds"
    propagate_at_launch = true
  }
}
