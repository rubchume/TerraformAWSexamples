variable "aws_region" {}
variable "aws_profile" {}

variable "deployment_tag" {}
variable "app_name" {}

variable "container_parameters" {
  type = list(object({
    image = string
    container_name = string
    public_port = number
  }))
}

variable "main_container" {
  type = string
}

variable "number_of_cpus" {
  type = number
  default = 256
}

variable "memory" {
  type = number
  default = 1024
}

variable "alb_idle_timeout" {
  type = number
  default = 60
}
