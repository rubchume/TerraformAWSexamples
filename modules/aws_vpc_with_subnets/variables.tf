variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Classless Inter-Domain Routing (CIDR) for the VPC. Usually, 10.0.0.0/16"
}

variable "private_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    private_subnet = {
      cidr_block        = "10.0.1.0/24",
      availability_zone = "eu-west-3a"
    }
  }
}

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    public_subnet = {
      cidr_block        = "10.0.101.0/24",
      availability_zone = "eu-west-3a"
    }
  }
}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "allowed_ports" {
  description = "Additional ports (in addition to 22) that are allowed for ingress TCP connections"
  type        = set(number)
  default     = []
}
