import json

def lambda_handler(event, context):
    # Your Python code goes here
    message = "Hello from Lambda!"
    print(message)  # Prints to CloudWatch logs

    return {
        'statusCode': 200,
        'body': json.dumps(message)
    }