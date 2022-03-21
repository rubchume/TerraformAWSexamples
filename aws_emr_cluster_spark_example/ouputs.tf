output "master_node_public_dns" {
  value = aws_emr_cluster.emr_cluster.master_public_dns
}

output "master_instance_security_group_for_notebook_use" {
  value = aws_security_group.master_instance_security_group_for_notebook_use.id
}

output "EMR_notebook_security_group_for_notebook_use" {
  value = aws_security_group.EMR_notebook_security_group_for_notebook_use.id
}
