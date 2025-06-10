#############
# VPC BLOCK #
#############

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.main_vpc.id
  count = 2
  cidr_block = var.public_subnets_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
}

resource "aws_db_subnet_group" "db" {
  name = "db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.public_subnets : subnet.id]
  tags = {
    Name = "DB subnet group"
  }
}


##########################
# INTERNET GATEWAY BLOCK #
##########################

resource "aws_internet_gateway" "vpc_main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

###############
# ROUTE BLOCK #
###############

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

}

resource "aws_route" "external_route_public" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.vpc_main_igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count = length(var.public_subnets_cidrs)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

########################
# SECURITY GROUP BLOCK #
########################

resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  name = "main_sg"
}

resource "aws_vpc_security_group_ingress_rule" "allow_all" { 
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}