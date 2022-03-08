output "emr_role_policy" {
  value = data.aws_iam_policy.emr_role_policy
}

output "ec2_role_policy" {
  value = aws_iam_policy.ec2_role_policy
}
