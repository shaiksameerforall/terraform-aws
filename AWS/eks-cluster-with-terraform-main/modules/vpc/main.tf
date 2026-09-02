# VPC Configuration
resource "aws_vpc" "eks_vpc" {
  cidr_block           = define_vpc_cidr  # TODO: Define VPC CIDR in variables.tf
  enable_dns_hostnames = true  
  enable_dns_support   = true  

  tags = {
    Project     = "EKS-Cluster"
    Environment = define-tag # TODO: Modify the environment tag
  }
}


# Public Subnets
resource "aws_subnet" "public" {
  count             = length(define_cidrs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = public_subnet_cidrs[count.index] # TODO
  availability_zone = add_availaability_zones[count.index]

  map_public_ip_on_launch = true  # Automatically assign a public IP address to instances

  tags = {
    Name    = "public-subnet-${count.index + 1}"  # TODO: Customize naming pattern
    Tier    = "public"
  }
}



resource "aws_subnet" "private" {
  count             = length(define_cidrs)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = private_subnet_cidrs[count.index] # TODO: Add availability zone 
  availability_zone = add_availaability_zones[count.index] # TODO: Add availability zone 

  map_public_ip_on_launch = true  # Automatically assign a public IP address to instances

  tags = {
    Name    = "private-subnet-${count.index + 1}"  # TODO: Customize naming pattern
    Tier    = "private"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "int-gw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "" # TODO: Add tag name
  }
}


# Elastic IPs
resource "aws_eip" "eip-nat" {
  count = length(add_public_subnet_cidrs)  # TODO: Add public subnet cidr
  domain = "vpc"

    # TODO: Optionally add tags here for better resource tracking
}


#NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  count         = length(add_public_subnet_cidrs)  # TODO: Add public subnet cidr
  allocation_id = aws_eip.eip-nat[count.index].id  
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}


# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Allows all outbound traffic
    gateway_id = aws_internet_gateway.int-gw.id
  }

  tags = {
    Name = ""    # TODO: Add tag name
  }
}


resource "aws_route_table" "private" {
  count = length(define.private_subnet_cidr)   #   Replace with private subnet cidr
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[count.index].id
  }

  tags = {
    Name = "private-RT-${count.index + 1}"  # TODO: Customize prefix or suffix if needed
  }
}



resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

