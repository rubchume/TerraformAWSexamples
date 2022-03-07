variable "deployment_tag" {
  type = string
  default = "default_tag"
  description = "A tag that will identify all resources created by current deployment"
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
