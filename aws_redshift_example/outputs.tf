output "redshift_cluster_endpoint" {
  value = aws_redshift_cluster.default.endpoint
}

output "redshift_cluster_dns_name" {
  value = aws_redshift_cluster.default.dns_name
}

output "redshift_cluster_port" {
  value = aws_redshift_cluster.default.port
}
