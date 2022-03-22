output "master_node_public_dns" {
  value = aws_emr_cluster.emr_cluster.master_public_dns
}

output "master_instance_security_group_for_notebook_use" {
  value = module.emr_notebook_security_groups.master_instance_security_group_for_notebook_use
}

output "EMR_notebook_security_group_for_notebook_use" {
  value = module.emr_notebook_security_groups.EMR_notebook_security_group_for_notebook_use
}
