output "ecr_repository_urls" {
  value = {
    for k, ecr in aws_ecr_repository.aws-ecr : k => ecr.repository_url
  }
}

output "exampleoutput" {
  value = "examplevalue"
}
