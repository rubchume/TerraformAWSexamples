output "redshift_cluster_endpoint" {
  value = aws_redshift_cluster.default.endpoint
}

output "redshift_cluster_port" {
  value = aws_redshift_cluster.default.port
}
