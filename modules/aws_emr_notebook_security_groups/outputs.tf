output "master_instance_security_group_for_notebook_use" {
  value = aws_security_group.EMR_notebook_security_group_for_notebook_use.id
}

output "EMR_notebook_security_group_for_notebook_use" {
  value = aws_security_group.EMR_notebook_security_group_for_notebook_use.id
}
