data "aws_iam_policy" "emr_role_policy_default" {
  arn = "arn:aws:iam::aws:policy/AmazonEMRFullAccessPolicy_v2"
}

data "aws_iam_policy_document" "emr_role_policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "emr_role_policy_extra" {
  name = var.emr_role_policy_name
  policy = data.aws_iam_policy_document.emr_role_policy_document.json
  tags = var.additional_tags
}

data "aws_iam_policy_document" "ec2_role_policy_document" {
  version = "2012-10-17"
  statement {
    resources = ["*"]
    actions   = [
      "cloudwatch:*",
      "dynamodb:*",
      "ec2:Describe*",
      "elasticmapreduce:Describe*",
      "elasticmapreduce:ListBootstrapActions",
      "elasticmapreduce:ListClusters",
      "elasticmapreduce:ListInstanceGroups",
      "elasticmapreduce:ListInstances",
      "elasticmapreduce:ListSteps",
      "kinesis:CreateStream",
      "kinesis:DeleteStream",
      "kinesis:DescribeStream",
      "kinesis:GetRecords",
      "kinesis:GetShardIterator",
      "kinesis:MergeShards",
      "kinesis:PutRecord",
      "kinesis:SplitShard",
      "rds:Describe*",
      "s3:*",
      "sdb:*",
      "sns:*",
      "sqs:*"
    ]
  }
}

resource "aws_iam_policy" "ec2_role_policy" {
  name = var.ec2_role_policy_name
  policy = data.aws_iam_policy_document.ec2_role_policy_document.json
  tags = var.additional_tags
}
