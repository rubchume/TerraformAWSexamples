variable "additional_tags" {
  default = {}
  description = "Additional resource tags"
  type = map(string)
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "idle_timeout" {
  type = number
}
