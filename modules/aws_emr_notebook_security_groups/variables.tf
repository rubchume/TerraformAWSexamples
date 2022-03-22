variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

variable "vpc_id" {
  description = "Id of the VPC where these security groups are going to be created"
  type = string
}
