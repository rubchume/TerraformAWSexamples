variable "repository_names" {
  description = "List of names of the repositories to be created"
  type    = list(string)
}

variable "deployment_tag" {
  default = ""
}
