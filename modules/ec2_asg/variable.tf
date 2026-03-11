variable "security_group_id" {
  type        = string
  description = "EC2 security group ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ASG"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "lb_dns_name" {
  type        = string
  description = "Load balancer DNS name"
}

variable "rds_host" {
  type        = string
  description = "RDS endpoint host"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}
