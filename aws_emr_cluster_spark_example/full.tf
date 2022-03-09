variable "aws_region" {}
variable "aws_profile" {}
variable "deployment_tag" {}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc_with_public_subnet" {
  source = "./modules/aws_vpc_public_subnet"

  additional_tags = {
    Deployment                               = var.deployment_tag,
    for-use-with-amazon-emr-managed-policies = true
  }
}

module "emr_service_role" {
  source = "./modules/aws_service_role"

  service_role_name = "emr_role"
  additional_tags = {
    Deployment = var.deployment_tag
  }
  service_principal = "elasticmapreduce.amazonaws.com"
}

module "ec2_service_role" {
  source = "./modules/aws_service_role"

  service_role_name = "EMR_EC2_DefaultRole"
  additional_tags = {
    Deployment = var.deployment_tag
  }
  service_principal = "ec2.amazonaws.com"
}

module "emr_role_policies" {
  source = "./modules/aws_emr_role_policies"

  additional_tags = {
    Deployment = var.deployment_tag
  }
}

resource "aws_iam_role_policy_attachment" "emr-role-policy-attach-default" {
  role       = module.emr_service_role.service_role.name
  policy_arn = module.emr_role_policies.emr_role_policy_default.arn
}

resource "aws_iam_role_policy_attachment" "emr-role-policy-attach-extra" {
  role       = module.emr_service_role.service_role.name
  policy_arn = module.emr_role_policies.emr_role_policy_extra.arn
}

resource "aws_iam_role_policy_attachment" "ec2-role-policy-attach" {
  role       = module.ec2_service_role.service_role.name
  policy_arn = module.emr_role_policies.ec2_role_policy.arn
}

resource "aws_iam_instance_profile" "emr_profile" {
  name = "ec2_profile"
  role = module.ec2_service_role.service_role.name
}

resource "aws_emr_cluster" "emr_cluster" {
  name          = "spark-app-udacity"
  release_label = "emr-5.28.0"
  applications  = ["Spark", "Zeppelin"]

  ec2_attributes {
    instance_profile = aws_iam_instance_profile.emr_profile.arn
    subnet_id        = module.vpc_with_public_subnet.subnet_id
  }

  master_instance_group {
    instance_type = "m5.xlarge"
  }

  core_instance_group {
    instance_count = 1
    instance_type  = "m5.xlarge"
  }

  service_role = module.emr_service_role.service_role.arn

  tags = {
    for-use-with-amazon-emr-managed-policies = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.emr-role-policy-attach-default,
    aws_iam_role_policy_attachment.emr-role-policy-attach-extra,
    aws_iam_role_policy_attachment.ec2-role-policy-attach
  ]
}
