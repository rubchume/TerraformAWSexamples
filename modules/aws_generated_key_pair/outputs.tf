output "key_pair" {
  value = aws_key_pair.generated_key
}

output "private_key" {
  value = tls_private_key.private_key
}
