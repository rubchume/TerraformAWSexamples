output "master_node_public_dns" {
  value = aws_emr_cluster.emr_cluster.master_public_dns
}
