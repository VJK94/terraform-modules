#Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "${var.env}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets

  #   enable_deletion_protection = false

  tags = {
    Name    = "${var.env}-app-lb"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create Application Load Balancer target group
resource "aws_lb_target_group" "app_tg" {
  name     = "${var.env}-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name    = "${var.env}-app-tg"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create Listener and link the load balancer
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
