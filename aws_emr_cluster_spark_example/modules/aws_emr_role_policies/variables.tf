variable "deployment_tag" {
  type = string
  default = "default_tag"
  description = "A tag that will identify all resources created by current deployment"
}

variable "emr_role_policy_name" {
  type = string
  default = "emr_role_policy"
}

variable "ec2_role_policy_name" {
  type = string
  default = "ec2_role_policy"
}
