variable "aws_region" {}
variable "aws_profile" {}
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

data "aws_iam_policy_document" "redshift_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }
  }
}

variable "dwh_iam_role_name" {}
resource "aws_iam_role" "redshift_role" {
  name               = var.dwh_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.redshift_role_assume_role_policy.json

  tags = {
    tag-key = "redshift-role"
  }
}

data "aws_iam_policy" "AmazonS3ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "sto-readonly-role-policy-attach" {
  role       = aws_iam_role.redshift_role.name
  policy_arn = data.aws_iam_policy.AmazonS3ReadOnlyAccess.arn
}

variable "vpc_cidr" {}
resource "aws_vpc" "redshift_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags             = {
    Name = "redshift-vpc"
  }
}

resource "aws_internet_gateway" "redshift_vpc_gw" {
  vpc_id     = aws_vpc.redshift_vpc.id
  depends_on = [
    aws_vpc.redshift_vpc
  ]
}

resource "aws_route_table" "redshift_vpc_route_table" {
  vpc_id = aws_vpc.redshift_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redshift_vpc_gw.id
  }
}

resource "aws_route_table_association" "redshift_route_table_subnet1_association" {
  subnet_id      = aws_subnet.redshift_subnet_1.id
  route_table_id = aws_route_table.redshift_vpc_route_table.id
}

resource "aws_route_table_association" "redshift_route_table_subnet2_association" {
  subnet_id      = aws_subnet.redshift_subnet_2.id
  route_table_id = aws_route_table.redshift_vpc_route_table.id
}

resource "aws_default_security_group" "redshift_security_group" {
  vpc_id = aws_vpc.redshift_vpc.id
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "redshift-sg"
  }
  depends_on = [
    aws_vpc.redshift_vpc
  ]
}

variable "redshift_subnet_cidr_1" {}
variable "redshift_subnet_cidr_2" {}
variable "subnet_availability_zone" {}
resource "aws_subnet" "redshift_subnet_1" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = var.redshift_subnet_cidr_1
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = "true"
  tags                    = {
    Name = "redshift-subnet-1"
  }
  depends_on = [
    aws_vpc.redshift_vpc
  ]
}
resource "aws_subnet" "redshift_subnet_2" {
  vpc_id                  = aws_vpc.redshift_vpc.id
  cidr_block              = var.redshift_subnet_cidr_2
  availability_zone       = var.subnet_availability_zone
  map_public_ip_on_launch = "true"
  tags                    = {
    Name = "redshift-subnet-2"
  }
  depends_on = [
    aws_vpc.redshift_vpc
  ]
}

resource "aws_redshift_subnet_group" "redshift_subnet_group" {
  name       = "redshift-subnet-group"
  subnet_ids = [aws_subnet.redshift_subnet_1.id, aws_subnet.redshift_subnet_2.id]
  tags       = {
    environment = "dev"
    Name        = "redshift-subnet-group"
  }
}

variable "rs_cluster_identifier" {}
variable "rs_database_name" {}
variable "rs_master_username" {}
variable "rs_master_pass" {}
variable "rs_nodetype" {}
variable "rs_cluster_type" {}
variable "rs_cluster_number_of_nodes" {}
resource "aws_redshift_cluster" "default" {
  cluster_identifier        = var.rs_cluster_identifier
  node_type                 = var.rs_nodetype
  cluster_type              = var.rs_cluster_type
  cluster_subnet_group_name = aws_redshift_subnet_group.redshift_subnet_group.id
  skip_final_snapshot       = true
  number_of_nodes           = var.rs_cluster_number_of_nodes

  database_name   = var.rs_database_name
  master_username = var.rs_master_username
  master_password = var.rs_master_pass

  default_iam_role_arn = aws_iam_role.redshift_role.arn
  iam_roles  = [aws_iam_role.redshift_role.arn]
  depends_on = [
    aws_vpc.redshift_vpc,
    aws_default_security_group.redshift_security_group,
    aws_redshift_subnet_group.redshift_subnet_group,
    aws_iam_role.redshift_role
  ]
}
