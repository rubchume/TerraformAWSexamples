output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "security_group" {
  value = aws_security_group.security_group
}

output "master_instance_security_group_for_notebook_use" {
  value = aws_security_group.master_instance_security_group_for_notebook_use
}

#output "EMR_notebook_security_group_for_notebook_use" {
#  value = aws_security_group.EMR_notebook_security_group_for_notebook_use
#}
