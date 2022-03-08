output "emr_role_policy_default" {
  value = data.aws_iam_policy.emr_role_policy_default
}

output "emr_role_policy_extra" {
  value = aws_iam_policy.emr_role_policy_extra
}

output "ec2_role_policy" {
  value = aws_iam_policy.ec2_role_policy
}
