 resource "aws_lambda_function" "my_lambda" {
      function_name    = var.function_name
      handler          = var.handler # Adjust based on your code
      runtime          = var.runtime   # Adjust based on your code
      role             = var.aws_iam_role
      filename         = var.filename # Path to your zipped code
      source_code_hash = filebase64sha256("/Users/priyadarshini/Desktop/infrastructure-as-code/modules/lambda/pythontest.zip")
 }
resource "aws_lambda_permission" "allow_s3_invoke" {
      statement_id  = "AllowExecutionFromS3Bucket"
      action        = "lambda:InvokeFunction"
      function_name = aws_lambda_function.my_lambda.function_name
      principal     = "s3.amazonaws.com"
      source_arn    = var.source_arn
    }

variable "function_name" {
  type = string
  default = "my-s3-event-lambda"
}

variable "handler" {
  type = string
  default = "pythontest.lambda_handler"
}

variable "runtime" {
  type = string
  default = "python3.12"
}

variable "filename" {
  type = string
  #default = pythontest.py
  default = "/Users/priyadarshini/Desktop/infrastructure-as-code/modules/lambda/pythontest.zip"
}

variable "aws_iam_role" {
  type = string
  default = "arn:aws:iam::654291821809:role/lambda_s3_trigger_role"
}
variable "source_arn" {
  type = string
  default = "arn:aws:s3:::my-mc-123456"
  
}

