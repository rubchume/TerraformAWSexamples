resource "aws_ecr_repository" "aws-ecr" {
  for_each = toset(var.repository_names)

  name = each.value

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Deployment = var.deployment_tag
  }
}

data local_file "output_variables_template" {
  filename = "${path.module}/output_variables_template.txt"
}

data template_file "output_variables_rendered" {
  template = data.local_file.output_variables_template.content

  for_each = aws_ecr_repository.aws-ecr

  vars = {
    ecr_repository_url=each.value.repository_url
    ecr_registry_id=each.value.registry_id
  }
}

resource "local_file" "output_variables" {
  for_each = data.template_file.output_variables_rendered

  filename = "output_variables_${each.key}.sh"
  content = each.value.rendered
}
