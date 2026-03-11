# NOTE: Bastion host is kept here for simplicity but ideally should be its own module

#EC2 instance for Bastion Host
resource "aws_instance" "bastion_host" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion_host_sg]
  associate_public_ip_address = true

  tags = {
    Name    = "Bastion_host-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

# Creating Database Subnet group under our VPC
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_subnet-${var.env}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name    = "My DB subnet group-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

# Launching RDS db instance
resource "aws_db_instance" "rds_mysql" {
  allocated_storage      = var.db_allocated_storage
  max_allocated_storage  = var.db_max_allocated_storage
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot    = true
  identifier             = "${var.env}-terraform-db"

  # performance_insights requires db.t3.medium or larger
  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7

  tags = {
    Project = "${var.env}_asg_ec2_rds"
  }
}
