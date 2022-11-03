variable "aws_lambda_function" {
  description = "The lambda function as Terraform resource. E.g.: aws_lambda_function.my_lambda_function_name"
  type = object({
    invoke_arn = string
    function_name = string
  })
}

variable "endpoint_path" {
  description = "The endpoint path that will redirect the call to the Lambda function"
  type = string
}
