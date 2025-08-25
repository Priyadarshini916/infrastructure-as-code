lambda_triggers = {
 "trigger1" = {
    lambda_function_arn = "arn:aws:lambda:us-east-1:654291821809:function:my-s3-event-lambda"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "uploads/"
    #filter_suffix       = ".jpg"
 }
}