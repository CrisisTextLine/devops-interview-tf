import json
import random

def lambda_handler(event, context):
    response = {
        'statusCode': 400
    }
    if 'resource' not in event.keys():
        return "Test"
    print(event)
    if random.randint(1,5) == 5:
        response['statusCode'] = 500
        return response
    if event['resource'] == "/healthcheck" and event['httpMethod'] == 'GET':
        response['statusCode'] = 200
        if random.randint(1,5) == 5:
            response['body'] = json.dumps({"health":"poor"})
        else:
            response['body'] = json.dumps({"health":"ok"})
    if event['resource'] == "/todo" and event['httpMethod'] == 'POST':
        response['statusCode'] = 200
        body = json.loads(event['body'])
        if 'title' in body.keys():
            response['body'] = event['body']
        else:
            response['body'] = json.dumps({"status":"invalid data: missing title"})
    if event['resource'] == "/todo" and event['httpMethod'] == 'GET':
        response['statusCode'] = 200
        response['body'] = json.dumps({"todoList":[
            "We're not actually saving your data anywhere; this is just a coding exercise.",
            "But good luck!",
            "- The CTL DevOps Team"
        ]})
    return response

