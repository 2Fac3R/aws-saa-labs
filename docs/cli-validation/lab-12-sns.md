# CLI Validation: Lab 12 - SNS Messaging

## 1. Verify SNS Topic and Subscriptions
Retrieve details of the active SNS topics and subscriptions to confirm they were successfully created:
```bash
# List all SNS topics
aws sns list-topics --query "Topics" --output json

# Describe the topic attributes
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, 'lab-orders')].TopicArn" --output text)
aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN"

# List subscriptions by topic
aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN" --query "Subscriptions" --output json
```

---

## 2. Verify SQS Queue Policy (Resource Access)
Ensure that the SQS queue policy has been configured correctly to allow SNS to publish messages directly to it:
```bash
# Get SQS queue URL
SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name "lab-standard-queue" --query "QueueUrl" --output text)

# Retrieve and inspect the access policy
aws sqs get-queue-attributes \
  --queue-url "$SQS_QUEUE_URL" \
  --attribute-names Policy \
  --query "Attributes.Policy" \
  --output text | jq .
```
Verify that the `Principal` matches `sns.amazonaws.com` and that the `Condition` matches the target SNS Topic ARN.

---

## 3. Test Pub/Sub Fan-Out via AWS CLI
Test the fan-out behavior by publishing a message directly to the SNS topic and verifying it propagates automatically to the SQS subscription:

Publish a test event to the SNS topic:
```bash
aws sns publish \
  --topic-arn "$SNS_TOPIC_ARN" \
  --message '{"event": "order_placed", "orderId": "CLI-12001", "amount": 99.99}' \
  --subject "New Order Dispatch"
```

Retrieve the message from the subscribed SQS queue:
```bash
aws sqs receive-message \
  --queue-url "$SQS_QUEUE_URL" \
  --attribute-names All \
  --wait-time-seconds 5
```
Verify that the output contains the SNS envelope structure with the published JSON payload in the `"Message"` field.

---

## 4. Clean Up (Acknowledge Message)
Extract the `ReceiptHandle` and delete the message to clear the queue:
```bash
RECEIPT_HANDLE=$(aws sqs receive-message \
  --queue-url "$SQS_QUEUE_URL" \
  --query "Messages[0].ReceiptHandle" \
  --output text)

aws sqs delete-message --queue-url "$SQS_QUEUE_URL" --receipt-handle "$RECEIPT_HANDLE"
```
