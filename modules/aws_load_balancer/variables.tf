variable "additional_tags" {
  default = {}
  description = "Additional resource tags"
  type = map(string)
}

variable "subnet_ids" {
  type = list(number)
}

variable "vpc_id" {
  type = number
}
