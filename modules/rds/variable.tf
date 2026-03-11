variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for Bastion Host"
}

variable "bastion_host_sg" {
  type        = string
  description = "Bastion Host security group ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}

variable "rds_sg_id" {
  type        = string
  description = "RDS security group ID"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for Bastion Host"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for Bastion Host"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_username" {
  type        = string
  description = "RDS master username"
}

variable "db_password" {
  type        = string
  description = "RDS master password"
  sensitive   = true
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB"
}

variable "db_max_allocated_storage" {
  type        = number
  description = "RDS max allocated storage in GB"
}

variable "db_engine_version" {
  type        = string
  description = "MySQL engine version"
}
