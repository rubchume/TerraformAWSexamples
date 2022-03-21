provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc_with_public_subnet" {
  source = "../modules/aws_vpc_public_subnet"

  additional_tags = {
    Deployment                               = var.deployment_tag,
    for-use-with-amazon-emr-managed-policies = true
  }
}

module "emr_service_role" {
  source = "../modules/aws_service_role"

  service_role_name = "emr_role"
  additional_tags = {
    Deployment = var.deployment_tag
  }
  service_principal = "elasticmapreduce.amazonaws.com"
}

module "ec2_service_role" {
  source = "../modules/aws_service_role"

  service_role_name = "EMR_EC2_DefaultRole"
  additional_tags = {
    Deployment = var.deployment_tag
  }
  service_principal = "ec2.amazonaws.com"
}

module "emr_role_policies" {
  source = "../modules/aws_emr_role_policies"

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

module "ec2_ssh_key_pair" {
  source = "../modules/aws_generated_key_pair"

  key_name = var.ec2_ssh_key_name
}

resource "aws_emr_cluster" "emr_cluster" {
  name          = "spark-app-udacity"
  release_label = "emr-5.28.0"
  applications  = ["Spark", "Zeppelin"]

  ec2_attributes {
    instance_profile                  = aws_iam_instance_profile.emr_profile.arn
    emr_managed_master_security_group = module.vpc_with_public_subnet.security_group.id
    emr_managed_slave_security_group  = module.vpc_with_public_subnet.security_group.id
    subnet_id                         = module.vpc_with_public_subnet.subnet_id
    key_name                          = module.ec2_ssh_key_pair.key_pair.key_name
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

resource "local_file" "ec2_key_pem" {
    content  = module.ec2_ssh_key_pair.private_key.private_key_pem
    filename = "${module.ec2_ssh_key_pair.key_pair.key_name}.pem"
}

data local_file "output_variables_template" {
  filename = "${path.module}/output_variables_template.txt"
}

data template_file "output_variables_rendered" {
  template = data.local_file.output_variables_template.content

  vars = {
    master_public_dns=aws_emr_cluster.emr_cluster.master_public_dns
    ec2_key_pem=local_file.ec2_key_pem.filename
  }
}

resource "local_file" "output_variables" {
  filename = "output_variables.sh"
  content = data.template_file.output_variables_rendered.rendered
}

resource "local_file" "connect_to_instance_script" {
  source = "${path.module}/connect_to_instance.sh"
  filename = "connect_to_instance_script.sh"
}

resource "local_file" "copy_file_to_instance_script" {
  source = "${path.module}/copy_file_to_instance.sh"
  filename = "copy_file_to_instance_script.sh"
}

resource "local_file" "ssh_port_forwarding_script" {
  source = "${path.module}/ssh_port_forwarding_to_master_node.sh"
  filename = "ssh_port_forwarding_script.sh"
}

resource "aws_security_group" "master_instance_security_group_for_notebook_use" {
  vpc_id = module.vpc_with_public_subnet.vpc.id
  tags   = {
    Deployment                               = var.deployment_tag,
    for-use-with-amazon-emr-managed-policies = true
  }

  ingress {
    protocol  = "tcp"
    from_port = 18888
    to_port   = 18888
    cidr_blocks = [module.vpc_with_public_subnet.vpc.cidr_block]
  }
}

resource "aws_security_group" "EMR_notebook_security_group_for_notebook_use" {
  vpc_id = module.vpc_with_public_subnet.vpc.id
  tags   = {
    Deployment                               = var.deployment_tag,
    for-use-with-amazon-emr-managed-policies = true
  }

  egress {
    protocol         = "tcp"
    from_port        = 18888
    to_port          = 18888
    cidr_blocks      = [module.vpc_with_public_subnet.vpc.cidr_block]
  }
}
