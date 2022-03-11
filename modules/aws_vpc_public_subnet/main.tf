resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags             = merge(var.additional_tags, { Name = "VPC" })
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = "true"
  tags                    = merge(var.additional_tags, { Name = "subnet" })
}

resource "aws_internet_gateway" "vpc_gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "vpc_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_gw.id
  }
}

resource "aws_route_table_association" "route_table_subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.vpc_route_table.id
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
  tags   = var.additional_tags

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
