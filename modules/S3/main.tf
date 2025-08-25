#create a s3 bucket and trigger a lambda function every time an event occurs in S3

resource "aws_s3_bucket" "buck" {
    bucket = var.bucket_name
}




resource "aws_s3_bucket_notification" "bucket-notify" {
  bucket = aws_s3_bucket.buck.id

    dynamic "lambda_function" {
    for_each = var.lambda_triggers
    content {
      lambda_function_arn = try(lambda_function.value.lambda_function_arn, null)
      events              = try(lambda_function.value.events, null)

    filter_prefix = try(lambda_function.value.filter_prefix, null)
    filter_suffix = try(lambda_function.value.filter_suffix, null)         

    }      
  }

}

variable "lambda_triggers" {
  type = map(object({
  lambda_function_arn = string
    events              = list(string)
    filter_prefix       = optional(string)
    filter_suffix       = optional(string)

      
 }))
  
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string 
  default = "my-mc-123456"
}


  