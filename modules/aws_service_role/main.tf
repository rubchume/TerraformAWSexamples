data "aws_iam_policy_document" "role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.service_principal]
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = var.service_role_name
  assume_role_policy = data.aws_iam_policy_document.role_assume_role_policy.json

  tags = {
    Deployment = var.deployment_tag
  }
}
