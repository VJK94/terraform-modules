#Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name    = "Project VPC-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create Subnets
resource "aws_subnet" "pub_sub" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name    = "${var.env} - Pub Sub ${count.index + 1}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

resource "aws_subnet" "priv_sub" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name    = "${var.env} - Priv Sub ${count.index + 1}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "custom_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "Project VPC IG-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create Custom Route Table for public subnets
resource "aws_route_table" "custom_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_igw.id
  }

  tags = {
    Name    = "Custom Route Table-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Associate public subnets to custom route table
resource "aws_route_table_association" "pub_sub_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.pub_sub[*].id, count.index)
  route_table_id = aws_route_table.custom_rt.id
}

#Create Elastic IP for NAT gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "Project VPC EIP-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Create NAT Gateway and attach elastic IP
resource "aws_nat_gateway" "custom_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.pub_sub[0].id

  tags = {
    Name    = "custom_nat_gw-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}

#Modify default route tables to add nat gateway
resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.custom_nat.id
  }

  tags = {
    Name    = "Default Route Table-${var.env}"
    Project = "${var.env}_asg_ec2_rds"
  }
}