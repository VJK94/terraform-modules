output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.pub_sub[0].id
}

output "public_subnet_ids" {
  value = aws_subnet.pub_sub[*].id
}

output "private_subnet_id" {
  value = aws_subnet.priv_sub[*].id
}