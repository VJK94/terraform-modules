output "rds_endpoint" {
  value       = split(":", aws_db_instance.rds_mysql.endpoint)[0]
  description = "RDS MySQL endpoint (host only)"
}

output "bastion_host_ip" {
  value       = aws_instance.bastion_host.public_ip
  description = "Bastion Host public IP"
}
