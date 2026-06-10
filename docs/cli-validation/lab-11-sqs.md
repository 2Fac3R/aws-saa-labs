# CLI Validation: Lab 11 - SQS Messaging

## 1. Verify SQS Queues
List the active queues to verify standard, FIFO, and DLQs were successfully created:
```bash
aws sqs list-queues --query "QueueUrls" --output json
```

Retrieve details for the standard queue to verify the visibility timeout, long polling settings, and redrive policy:
```bash
# Get standard queue URL
STD_URL=$(aws sqs get-queue-url --queue-name "lab-standard-queue" --query "QueueUrl" --output text)

# Get attributes
aws sqs get-queue-attributes --queue-url "$STD_URL" --attribute-names All
```

Retrieve details for the FIFO queue to verify FIFO properties and content-based deduplication:
```bash
# Get FIFO queue URL
FIFO_URL=$(aws sqs get-queue-url --queue-name "lab-fifo-queue.fifo" --query "QueueUrl" --output text)

# Get attributes
aws sqs get-queue-attributes --queue-url "$FIFO_URL" --attribute-names All
```

---

## 2. Test Messaging via AWS CLI (Basic Check)
Send a test message to the standard queue using the CLI:
```bash
aws sqs send-message --queue-url "$STD_URL" --message-body "CLI Standard Test Message"
```

Receive and print the message using the CLI:
```bash
aws sqs receive-message --queue-url "$STD_URL" --attribute-names All
```

Note the `ReceiptHandle` from the response, then delete the message to acknowledge successful processing:
```bash
RECEIPT_HANDLE=$(aws sqs receive-message --queue-url "$STD_URL" --query "Messages[0].ReceiptHandle" --output text)

aws sqs delete-message --queue-url "$STD_URL" --receipt-handle "$RECEIPT_HANDLE"
```

---

## 3. Run and Test FastAPI & Worker (Behavioral Check)

### Setup Environment
Export the SQS queue URLs generated from Terraform:
```bash
# From project root
export STANDARD_QUEUE_URL=$(terraform -chdir=terraform/messaging output -raw standard_queue_url)
export FIFO_QUEUE_URL=$(terraform -chdir=terraform/messaging output -raw fifo_queue_url)
export AWS_REGION="us-east-1"
```

### Start the FastAPI API (Producer)
Install dependencies and run the API server locally:
```bash
pip install -r apps/fastapi-worker/requirements.txt
uvicorn apps.fastapi-worker.api:app --host 0.0.0.0 --port 8000
```

### Send Messages to Queues
In a separate terminal, dispatch messages using `curl`:

**Standard Queue Test:**
```bash
curl -X POST "http://localhost:8000/send-standard" \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello Standard SQS Order #1001"}'
```

**FIFO Queue Test (Requires Message Group ID):**
```bash
curl -X POST "http://localhost:8000/send-fifo" \
     -H "Content-Type: application/json" \
     -d '{"message": "Hello FIFO SQS Order #1002", "message_group_id": "order-group-a"}'
```

### Start SQS Workers (Consumers)
In separate terminals, run the worker to consume messages from the queues:

**Process Standard Queue:**
```bash
python apps/fastapi-worker/worker.py --queue-url "$STANDARD_QUEUE_URL"
```

**Process FIFO Queue:**
```bash
python apps/fastapi-worker/worker.py --queue-url "$FIFO_QUEUE_URL"
```

---

## 4. Verify Dead Letter Queue (DLQ) Redrive Policy
Test SQS's ability to migrate failing messages to the DLQ after `maxReceiveCount` (3) is exceeded.

1. Send a poison message to the standard queue:
   ```bash
   aws sqs send-message --queue-url "$STANDARD_QUEUE_URL" --message-body "Poison Pill: This will fail 3 times"
   ```

2. Start the worker in **failure simulation mode**:
   ```bash
   python apps/fastapi-worker/worker.py --queue-url "$STANDARD_QUEUE_URL" --simulate-failure
   ```
   *Note: Watch the worker pull the message. It will sleep and log a processing failure without deleting the message.*
   *Allow the message visibility timeout (30 seconds) to expire so the worker pulls the message 3 times in total.*

3. Verify that the message is automatically moved to the Dead Letter Queue:
   ```bash
   # Get standard DLQ URL
   STD_DLQ_URL=$(aws sqs get-queue-url --queue-name "lab-standard-dlq" --query "QueueUrl" --output text)

   # Check message count on DLQ
   aws sqs get-queue-attributes --queue-url "$STD_DLQ_URL" --attribute-names ApproximateNumberOfMessages
   ```
   The `ApproximateNumberOfMessages` attribute should now return `1`.

4. Retrieve the poison message from the DLQ:
   ```bash
   aws sqs receive-message --queue-url "$STD_DLQ_URL"
   ```
