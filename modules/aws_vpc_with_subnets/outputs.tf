output "vpc" {
  value = aws_vpc.vpc
}

output "public_subnet_ids" {
  value = {
    for subnet_name, subnet in aws_subnet.public_subnets : subnet_name => subnet.id
  }
}

output "private_subnet_ids" {
  value = {
    for subnet_name, subnet in aws_subnet.private_subnets : subnet_name => subnet.id
  }
}

output "security_group" {
  value = aws_security_group.security_group
}
