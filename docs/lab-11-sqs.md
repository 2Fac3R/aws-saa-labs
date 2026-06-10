# Lab 11: Amazon SQS (Simple Queue Service)

## Objective
Build a decoupled architecture using Amazon SQS standard and FIFO queues with Dead Letter Queues (DLQs). You will use a FastAPI application to publish messages (producers), and a Python worker script to consume them (consumers), demonstrating message deduplication, visibility timeouts, and redrive behavior.

## Architecture
![Lab 11 Architecture](../diagrams/lab-11-sqs.svg)

## Key Concepts

### 1. Standard vs. FIFO Queues
* **Standard Queues:**
  * **Throughput:** Near-infinite transactions per second (TPS).
  * **Ordering:** Best-effort ordering (no strict guarantees).
  * **Delivery:** At-least-once delivery. Duplicate messages are possible.
* **FIFO Queues (First-In-First-Out):**
  * **Throughput:** Limited to 300 transactions/sec (without batching) or up to 3,000 transactions/sec (with batching).
  * **Ordering:** Strict first-in-first-out ordering.
  * **Delivery:** Exactly-once delivery. Duplicates are automatically removed within a 5-minute deduplication window.
  * **Naming:** Queue names **must** end with the `.fifo` suffix.
  * **Identifiers:** Requires a `MessageGroupId` (to group messages for parallel processing) and optionally a `MessageDeduplicationId` (unless content-based deduplication is enabled).

### 2. Dead Letter Queues (DLQ)
A DLQ is an SQS queue designated to receive messages that fail processing after a certain number of attempts. This prevents "poison pill" messages from clogging the queue.
* **Redrive Policy:** Connects the primary queue to the DLQ. It defines the `maxReceiveCount` (how many times a message can be polled and not deleted before being migrated to the DLQ).

### 3. Visibility Timeout
When a worker receives a message, SQS keeps it in the queue but hides it from other workers. This "invisible" state lasts for the duration of the **Visibility Timeout** (default: 30 seconds).
* **If processing succeeds:** The worker deletes the message from SQS before the timeout ends.
* **If processing fails/times out:** The message becomes visible again in the queue for other workers to pull.

### 4. Long Polling vs. Short Polling
* **Short Polling:** SQS queries a subset of servers and returns immediately, even if no messages are found. This increases empty retrieves and API costs.
* **Long Polling (WaitTimeSeconds > 0):** SQS waits for messages to arrive up to a maximum of 20 seconds. This reduces empty receives, saves on SQS cost, and increases efficiency. We configure `receive_wait_time_seconds = 10` in this lab.

---

## Implementation Details
* **Standard Queue:** `lab-standard-queue` (DLQ: `lab-standard-dlq`)
* **FIFO Queue:** `lab-fifo-queue.fifo` (DLQ: `lab-fifo-dlq.fifo`, content-based deduplication enabled)
* **Visibility Timeout:** 30 seconds
* **Max Receive Count:** 3 attempts before DLQ migration

---

## SAA Exam Takeaways
* **Decoupling:** SQS is the premier service for decoupling microservices to handle traffic spikes and prevent cascading failures.
* **FIFO Limitations:** Choose FIFO *only* when ordering and deduplication are strictly required. Otherwise, favor standard queues for maximum throughput and scale.
* **DLQs and Troubleshooting:** Always use a DLQ to isolate bad requests. Use **Amazon Athena** or redrive messages to inspect/re-process them.
* **Auto-Scaling:** You can scale EC2/Fargate instances based on SQS queue size (specifically using the `ApproximateNumberOfMessagesVisible` CloudWatch metric).
* **Message Size:** The maximum message size is **256 KB**. For larger payloads (up to 2 GB), use the **SQS Extended Client Library** with Amazon S3.
