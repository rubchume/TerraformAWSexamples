resource "aws_security_group" "master_instance_security_group_for_notebook_use" {
  name   = "SecurityGroup-MasterInstance-NotebookUse"
  vpc_id = var.vpc_id
  tags   = var.additional_tags
}

resource "aws_security_group" "EMR_notebook_security_group_for_notebook_use" {
  name   = "SecurityGroup-EMRnotebook-NotebookUse"
  vpc_id = var.vpc_id
  tags   = var.additional_tags
}

resource "aws_security_group_rule" "EMR_notebook_security_group_rule_ingress" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 18888
  to_port                  = 18888
  security_group_id        = aws_security_group.master_instance_security_group_for_notebook_use.id
  source_security_group_id = aws_security_group.EMR_notebook_security_group_for_notebook_use.id
}

resource "aws_security_group_rule" "EMR_notebook_security_group_rule_egress" {
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 18888
  to_port                  = 18888
  security_group_id        = aws_security_group.EMR_notebook_security_group_for_notebook_use.id
  source_security_group_id = aws_security_group.master_instance_security_group_for_notebook_use.id
}
