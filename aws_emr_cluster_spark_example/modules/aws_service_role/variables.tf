variable "additional_tags" {
  default = {}
  description = "Additional resource tags"
  type = map(string)
}

variable "service_principal" {
  type = string
  nullable = false
  description = "Service Principal of the service that will assume the role"
}

variable "service_role_name" {
  type = string
  default = "service_role"
  description = "Service role name"
}
