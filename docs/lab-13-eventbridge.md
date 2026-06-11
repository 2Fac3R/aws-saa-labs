# Lab 13: Amazon EventBridge (Event Buses and Scheduled Jobs)

## Objective
Build an **event-driven and scheduled automation architecture** using Amazon EventBridge. Configure a scheduled rule on the default event bus to invoke a serverless cron job (Lambda function) every minute, and set up a custom event bus routing specific custom events to a target SQS queue.

## Architecture
![Lab 13 Architecture](../diagrams/lab-13-eventbridge.svg)

## Key Concepts

### 1. Default vs. Custom Event Buses
* **Default Event Bus:** Exists by default in every AWS account. It automatically receives events from AWS services (e.g., EC2 state changes, S3 API calls via CloudTrail).
* **Custom Event Bus:** Created explicitly for custom applications and microservices. Decouples event publishers (like a frontend/API service) from event consumers.

### 2. Event Rules and Patterns
Rules match incoming JSON events against specific patterns. An event pattern filters events by fields such as `source` and `detail-type`:
```json
{
  "source": ["custom.order.service"],
  "detail-type": ["OrderCreated"]
}
```
Only matching events are routed to targets, minimizing unnecessary downstream processing.

### 3. Scheduled/Cron Rules
EventBridge supports two expressions for running jobs at specific intervals:
* **Rate Expressions:** e.g., `rate(1 minute)` or `rate(2 hours)`. Simplest for fixed intervals.
* **Cron Expressions:** e.g., `cron(0 12 * * ? *)` (runs at 12:00 PM UTC daily). Allows complex calendar-based schedules.

### 4. Target Access Policies
To route events to targets, EventBridge must be authorized:
* **Lambda Target:** Requires a resource-based policy (`aws_lambda_permission`) allowing `events.amazonaws.com` to execute the `lambda:InvokeFunction` action.
* **SQS Target:** Requires a queue policy (`aws_sqs_queue_policy`) granting `sqs:SendMessage` to `events.amazonaws.com` restricted to the rule's ARN.

---

## Implementation Details
* **Scheduled Job (Cron):**
  * Rule: `lab-cron-rule` on the `default` bus, running at `rate(1 minute)`.
  * Target: Lambda function `lab-cron-worker` (logs incoming events).
* **Event-Driven Routing:**
  * Bus: `lab-custom-bus`.
  * Rule: `lab-order-rule` (filters for `source = "custom.order.service"` and `detail-type = "OrderCreated"`).
  * Target: SQS Queue `lab-eventbridge-queue`.

---

## SAA Exam Takeaways
* **EventBridge (formerly CloudWatch Events)** is a serverless, highly scalable event bus. Use it to build event-driven, decoupled architectures.
* **Scheduled tasks:** EventBridge is the primary service for scheduling serverless jobs (e.g., triggering a Lambda or ECS task every hour).
* **Cross-account event routing:** EventBridge can receive and route events between different AWS accounts.
* **SaaS Integration:** EventBridge supports direct, partner-event integrations with third-party platforms (e.g., Datadog, Zendesk, Auth0) without writing custom webhook listeners.
* **EventBridge Scheduler vs. Rules:** EventBridge Scheduler is preferred for millions of unique, one-time or recurring tasks, while Rules are preferred for routing events from AWS services or custom applications.
