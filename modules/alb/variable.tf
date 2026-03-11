variable "security_group_id" {
  type        = string
  description = "ALB security group ID"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets for ALB"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "env" {
  type        = string
  description = "Environment name"
}
