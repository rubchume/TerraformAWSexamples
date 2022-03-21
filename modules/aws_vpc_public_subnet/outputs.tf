output "vpc" {
  value = aws_vpc.vpc
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "security_group" {
  value = aws_security_group.security_group
}
