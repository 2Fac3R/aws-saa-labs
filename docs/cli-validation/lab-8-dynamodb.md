# CLI Validation: Lab 8 - DynamoDB

## 1. Verify Table Configuration
```bash
# Check status and primary key
aws dynamodb describe-table --table-name "lab-orders-table" --query "Table.{Status:TableStatus, Billing:BillingModeSummary.BillingMode, PK:AttributeDefinitions[?Name=='PK'].AttributeName}"
```

## 2. Verify GSI and TTL
```bash
# List GSIs
aws dynamodb describe-table --table-name "lab-orders-table" --query "Table.GlobalSecondaryIndexes[*].IndexName"

# Check TTL status
aws dynamodb describe-time-to-live --table-name "lab-orders-table" --query "TimeToLiveDescription.TimeToLiveStatus"
```

## 3. Test Data Operations
```bash
# 1. Put an Item
aws dynamodb put-item \
    --table-name "lab-orders-table" \
    --item '{
        "PK": {"S": "USER#100"},
        "SK": {"S": "ORDER#2026-05-11"},
        "Status": {"S": "PENDING"},
        "Total": {"N": "150.50"}
    }'

# 2. Get the Item
aws dynamodb get-item \
    --table-name "lab-orders-table" \
    --key '{"PK": {"S": "USER#100"}, "SK": {"S": "ORDER#2026-05-11"}}'

# 3. Query via GSI (Find all PENDING orders)
aws dynamodb query \
    --table-name "lab-orders-table" \
    --index-name "StatusIndex" \
    --key-condition-expression "#s = :v" \
    --expression-attribute-names '{"#s": "Status"}' \
    --expression-attribute-values '{":v": {"S": "PENDING"}}'
```
