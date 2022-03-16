variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "emr_role_policy_name" {
  type    = string
  default = "emr_role_policy"
}

variable "ec2_role_policy_name" {
  type    = string
  default = "ec2_role_policy"
}
