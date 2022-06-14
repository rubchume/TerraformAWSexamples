variable "aws_region" {}
variable "aws_profile" {}

variable "deployment_tag" {}
variable "app_name" {}

variable "container_parameters" {
  type = list(object({
    image = string
    container_name = string
    public_ports = list(number)
  }))
}
