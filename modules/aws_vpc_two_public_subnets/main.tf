resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = {
    Deployment = var.deployment_tag
    Name = "VPC"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_1
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = "true"
  tags                    = {
    Name = "subnet-1"
    Deployment = var.deployment_tag
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr_2
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = "true"
  tags                    = {
    Name = "subnet-2"
    Deployment = var.deployment_tag
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_internet_gateway" "vpc_gw" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_gw.id
  }
}

resource "aws_route_table_association" "route_table_subnet1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_route_table_association" "route_table_subnet2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_default_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Deployment = var.deployment_tag
  }
  depends_on = [
    aws_vpc.vpc
  ]
}
