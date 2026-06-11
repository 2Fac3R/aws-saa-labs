# CLI Validation: Lab 13 - EventBridge Integration

## 1. Verify Scheduled Rule and Lambda Integration
Retrieve details of the active scheduled rule to confirm it is configured on the default event bus:
```bash
# Describe the scheduled rule
aws events describe-rule --name "lab-cron-rule" --output json

# Check the target of the scheduled rule
aws events list-targets-by-rule --rule "lab-cron-rule" --output json
```

Check the CloudWatch Logs to verify that the scheduled worker is running and executing the Lambda function:
```bash
# List log streams for the worker
aws logs describe-log-streams \
  --log-group-name "/aws/lambda/lab-cron-worker" \
  --order-by "LastEventTime" \
  --descending \
  --limit 3 \
  --query "logStreams[*].logStreamName" \
  --output json

# Retrieve the latest logs (replace LOG_STREAM_NAME with an entry from the command above)
aws logs get-log-events \
  --log-group-name "/aws/lambda/lab-cron-worker" \
  --log-stream-name "LOG_STREAM_NAME" \
  --limit 20 \
  --query "events[*].message" \
  --output table
```

---

## 2. Verify Custom Event Bus and Rules
Describe the custom EventBridge event bus and its corresponding rules:
```bash
# Describe the custom bus
aws events describe-event-bus --name "lab-custom-bus" --output json

# Describe the order filtering rule on the custom bus
aws events describe-rule --name "lab-order-rule" --event-bus-name "lab-custom-bus" --output json

# Check the targets for the rule
aws events list-targets-by-rule --rule "lab-order-rule" --event-bus-name "lab-custom-bus" --output json
```

---

## 3. Test Custom Event Routing (Service Integration)
Publish a mock event matching the rule pattern to the custom event bus:
```bash
aws events put-events --entries '[
  {
    "EventBusName": "lab-custom-bus",
    "Source": "custom.order.service",
    "DetailType": "OrderCreated",
    "Detail": "{\"orderId\": \"EB-13001\", \"amount\": 149.99, \"item\": \"Wireless Earbuds\"}"
  }
]'
```

Verify that the custom event has been filtered and routed successfully to the target SQS queue:
```bash
# Get SQS queue URL
SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name "lab-eventbridge-queue" --query "QueueUrl" --output text)

# Receive message from SQS queue
aws sqs receive-message \
  --queue-url "$SQS_QUEUE_URL" \
  --attribute-names All \
  --wait-time-seconds 5
```
Ensure that the message body matches the custom event details.

---

## 4. Clean Up (Acknowledge Message)
Extract the `ReceiptHandle` and delete the test message from the queue:
```bash
RECEIPT_HANDLE=$(aws sqs receive-message \
  --queue-url "$SQS_QUEUE_URL" \
  --query "Messages[0].ReceiptHandle" \
  --output text)

aws sqs delete-message --queue-url "$SQS_QUEUE_URL" --receipt-handle "$RECEIPT_HANDLE"
```
