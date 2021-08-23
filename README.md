#Email instructions (3 hour timeline):

##Part 1:
We have a simple web app for ToDo lists. We'd like to set up some basic monitoring of the application.
Given the endpoint:
`https://u3mpbqz6ki.execute-api.us-east-1.amazonaws.com/prod/healthcheck`
Write a health check script in the language of your choice which sends a request to the endpoint, and parses the response.
Anything other than `{"health":"ok"}` is considered an error.

Given that the health check above is successful, perform another request on the endpoint:
`https://u3mpbqz6ki.execute-api.us-east-1.amazonaws.com/prod/todo`
This endpoint accepts JSON POSTs in the form of `{"title": "walk the dog"}`
Your script should parse the response and throw an error for any non-200 response.

##Part 2:
Write a script to deploy your health check. It can be deployed as an AWS Lambda, as something that runs directly on a virtual machine, or as any other service with which you feel comfortable (which you feel can showcase a basic knowledge and experience of deployment processes). 
Since we don't have a test AWS account for you, please use pseudo-code. We don't expect the script to work perfectly as written. 
You can assume VPCs, Security Groups, Access Keys, Jenkins, etc. are all set up and you have access to them.

Requirements are:
send an exit code `0` if successful, `1` if warning, and `2` if error.
status `400` responses are considered warnings
status `500` responses are considered errors.
The script should execute every 5 minutes.

