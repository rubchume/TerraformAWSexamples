output "ecr_repository_variables" {
  value = {
    for k, ecr in aws_ecr_repository.aws-ecr : k => {
      repository_url=ecr.repository_url,
      registry_id=ecr.registry_id,
      registry_url=element(split("/", ecr.repository_url), 0)
    }
  }
}
