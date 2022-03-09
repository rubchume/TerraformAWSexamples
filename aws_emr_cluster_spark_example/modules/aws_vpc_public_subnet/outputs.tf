output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "default_security_group" {
  value = aws_default_security_group.default_security_group
}

output "security_group" {
  value = aws_security_group.security_group
}
