#Create a security group for Bastion host to allow only SSH
resource "aws_security_group" "bast_host_sg" {
  name        = "${var.env}_bast_host_sg"
  description = "Allow only SSH"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.env}_bast_host_sg"
    Project = "${var.env}_asg_ec2_rds"
  }

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#Create a security group for RDS to allow only connection from EC2 and Bastion Host
resource "aws_security_group" "rds_sg" {
  name        = "${var.env}_rds_sg"
  description = "Allow only MYSQL port from EC2 and Bastion"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.env}_rds_sg"
    Project = "${var.env}_asg_ec2_rds"
  }

  ingress {
    description     = "Allow MySQL from EC2 and Bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id, aws_security_group.bast_host_sg.id]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#Create a security group for autoscaling EC2 to allow HTTP and SSH from Bastion only
resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}_ec2_sg"
  description = "Allow HTTP from all and SSH from Bastion only"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.env}_ec2_sg"
    Project = "${var.env}_asg_ec2_rds"
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "Allow SSH from Bastion Host only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bast_host_sg.id]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#Create a security group for application load balancer
resource "aws_security_group" "alb_sg" {
  name        = "${var.env}_alb_sg"
  description = "Allow HTTP"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.env}_sg_alb"
    Project = "${var.env}_asg_ec2_rds"
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
