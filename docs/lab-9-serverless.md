# Lab 9: Lambda + API Gateway (Event-Driven Architecture)

## Objective
Build a fully serverless REST API that accepts incoming data via API Gateway, processes it with an AWS Lambda function, and persists it in a DynamoDB table.

## Architecture
![Lab 9 Architecture](../diagrams/lab-9-serverless.svg)

## Key Concepts

### 1. AWS Lambda
A serverless, event-driven compute service that lets you run code without provisioning or managing servers. 
- **Execution Role:** Every Lambda function has an IAM role that grants it permission to access other AWS services (like DynamoDB and CloudWatch).
- **Stateless:** Lambda functions are short-lived and stateless; any persistent data must be stored elsewhere.

### 2. Amazon API Gateway
A fully managed service that makes it easy for developers to create, publish, maintain, monitor, and secure APIs at any scale.
- **REST API:** We used a REST API (v1) to handle HTTP methods.
- **Lambda Proxy Integration:** This allows API Gateway to pass the entire HTTP request to the Lambda function and use the function's response as the HTTP response.

### 3. Event-Driven Design
The application only runs when an event occurs (an HTTP request). You only pay for the execution time of the Lambda and the number of requests to the API Gateway and DynamoDB.

## Implementation Details
- **Runtime:** Python 3.12
- **Integration:** API Gateway triggers Lambda via \`aws_lambda_permission\`.
- **Modularity:** Fetches DynamoDB table details from the Lab 8 state.
- **Deployment:** Lambda code is packaged as a ZIP and uploaded to S3 ("Architect Way").

## SAA Exam Takeaways
- **Lambda Limits:** 15-minute timeout, 10GB memory max, 1000 concurrent executions (soft limit).
- **Cold Starts:** The delay when a function is invoked for the first time in a while.
- **Security:** Use Resource-Based Policies (\`aws_lambda_permission\`) to allow API Gateway to trigger Lambda.
