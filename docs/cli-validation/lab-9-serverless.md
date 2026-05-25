# CLI Validation: Lab 9 - Serverless API

## 1. Verify Lambda Configuration
```bash
# Check if the function exists and its runtime
aws lambda get-function --function-name "lab-order-processor" --query "Configuration.{Runtime:Runtime, Role:Role, Handler:Handler}"
```

## 2. Verify API Gateway
```bash
# List APIs and get the ID for 'lab-order-api'
API_ID=$(aws apigateway get-rest-apis --query "items[?name=='lab-order-api'].id" --output text)

# Get the deployment stage URL
aws apigateway get-stages --rest-api-id $API_ID --query "item[*].stageName"
```

## 3. Test the API (Behavioral Check)
Send a POST request to your API and check if the order appears in DynamoDB.
```bash
# Get the URL from outputs (Run this from the project root)
INVOKE_URL=$(terraform -chdir=terraform/serverless-api output -raw api_url)

# IF you are already inside terraform/serverless-api, use:
# INVOKE_URL=$(terraform output -raw api_url)

# Send POST request
curl -X POST "$INVOKE_URL" \
    -H "Content-Type: application/json" \
    -d '{
        "userId": "USER#200",
        "orderId": "ORDER#PIPELINE-TEST",
        "total": "99.99"
    }'

# Verify in DynamoDB (Lab 8 validation)
aws dynamodb get-item \
    --table-name "lab-orders-table" \
    --key '{"PK": {"S": "USER#200"}, "SK": {"S": "ORDER#PIPELINE-TEST"}}'
```

## 4. View Lambda Logs
```bash
# Check CloudWatch logs for the execution results
aws logs describe-log-streams --log-group-name "/aws/lambda/lab-order-processor" --limit 1 --order-by "LastEventTime" --descending
```
