variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "Classless Inter-Domain Routing (CIDR) for the VPC. Usually, 10.0.0.0/16"
}

variable "deployment_tag" {
  type = string
  default = "default_tag"
  description = "A tag that will identify all resources created by current deployment"
}

variable "subnet_cidr_1" {
  type = string
  default = "10.0.1.0/24"
  description = "Subnet 1 CIDR"
}

variable "subnet_cidr_2" {
  type = string
  default = "10.0.2.0/24"
  description = "Subnet 2 CIDR"
}

variable "subnet_availability_zone" {
  type = string
  default = "eu-west-3a"
  description = "Availability zone in the region for the VPC subnets"
}
